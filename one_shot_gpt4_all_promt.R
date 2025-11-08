# Install packages
install.packages(c("httr", "stringr","jasonlite","openai"))

# Load Libraries
library(httr)
library(stringr)
library(readxl)
library(jsonlite)
library(openai)

# establish the connection between R and our chatGPT account
gpt_api <- "Add your gpt API"

# copy the file with input summary and provide instruction
cancer_data <- read.csv("Adv_cancer_test_10.csv")
dim(cancer_data)

#Subset small data first
cancer_new<-cancer_data[1:200,]
input <- cancer_new$TEXT
#patient_id <- cancer_new$`Patient ID`
#instruction <- cancer_data1$Instruction

# Common instruction to be followed for all messages: run 1 by 1

#Prompt 1
common_instruction <- "Please act as a healthcare professional and classify if the patients has metastatic cancer or not using following step:
1.Identify if patient has metastatic cancer or not.
2.Based on the information please provide a concise response as either 'Yes' or ‘No'.
Refer to below Example:
'Input1':'appropriate hpi is below ms is an asthmacopd who returns with shortness of breath after being discharged today she was originally admitted with of worsening shortness of breath and wheezing and was treated for copd exacerbation after an uri she had been started on course of steroids and completed course of azithromycin she arrived home at pm and at approximately she developed shortness of breath while sitting on the couch and told her daughter to call the ambulance she felt dizzy at the time she had no associated chest pain diaphoresis nausea she denies fevers chills palpitations abdominal pain she states that she was concerned about leaving the hospital today because she was started on new antihypertensive she says she does not do well with new medications and was worried about how it would affect her she took diltiazem mg this morning and reports weakness and fatigue beginning this morning it'
'Response1':'no'"

#Prompt2
common_instruction  = list(
  list(
    "role" = "system",
    "content" = "Please act as a curator and analyze the following discharge summary, classify if the patient has metastatic cancer or not. Let's think step by step.Choose the final answer from the list {Yes, No}"
  ),
  list(
    "role" = "user",
    "content" = "appropriate hpi is below ms is an asthmacopd who returns with shortness of breath after being discharged today she was originally admitted with of worsening shortness of breath and wheezing and was treated for copd exacerbation after an uri she had been started on course of steroids and completed course of azithromycin she arrived home at pm and at approximately she developed shortness of breath while sitting on the couch and told her daughter to call the ambulance she felt dizzy at the time she had no associated chest pain diaphoresis nausea she denies fevers chills palpitations abdominal pain she states that she was concerned about leaving the hospital today because she was started on new antihypertensive she says she does not do well with new medications and was worried about how it would affect her she took diltiazem mg this morning and reports weakness and fatigue beginning this morning it"
  ),
  list(
    "role" = "assistant",
    "content" = "no"
  )
)

## Initialize an empty character vector
response1 <- character(0)
response2 <- character(0)
pred <- NULL

# Input size can be anything from 1500,3000
# Choose 

# Create a list of messages with the common questions, and instructions
question <- list(list(role = "assistant", content = common_instruction))

for (i in 1:length(input)) {
  
  # Truncate input to avoid token limitations, assuming 100 tokens reserved for other text
  truncated_input <- str_trunc(input[i], 1500)
  #messages <- append(messages, list(list(role = "user", content = input[i])))
  
  # Append the truncated input message
  messages <- append(question, list(list(role = "user", content = truncated_input)))
  
  # send each message to get the output from gpt
  chatGPT_response <- POST(
    # use chatGPT website (you can copy paste)
    url = "https://api.openai.com/v1/chat/completions",
    # Authorize
    add_headers(Authorization = paste("Bearer", gpt_api)),
    # Output type: use JSON
    content_type_json(),
    # encode the value to json format
    encode = "json",
    # Controlling what to show as the output, it's going to be a list of following things
    body = list(
      model = "gpt-4", # Use gpt-3.5 is very fast
      messages = messages,
      temperature=0.2,max_tokens=20
    )
  )
  
  # Check and print status code
  #print(httr::status_code(chatGPT_response))
  
  #Extract and format the response
  answer_gpt1 <- content(chatGPT_response)$choices[[1]]$message$content
  answer_gpt2 <- tolower(substr(content(chatGPT_response)$choices[[1]]$message$content, 1, 3))
  
  # Append the response to the character vectors
  response1 <- c(response1, answer_gpt1)
  response2 <- c(response2, answer_gpt2)
  
  # if the response contain "Yes" then assign 1 orelse 0
  response <- ifelse(str_detect(tolower(answer_gpt1),"no")=="TRUE",0,1)
  pred<-c(pred,response)
} 

# Run the dataset in chunks and combine 
pred <- as.factor(pred)
n <- length(pred)

#depending on the length of pred choose only those rows
actual <- as.factor(cancer_new$Advanced.Cancer[1:n])
input <- input[1:n]

# run each of the the dataset and rename as r1 r2 and so on....
one_shot_r1 <- data.frame(actual,pred,input)

oneshot_gpt4_prompt1_1500 <- rbind(one_shot_r1,one_shot_r2)

#Confusion matrix
library(caret)
confusionMatrix(data=oneshot_gpt4_prompt1_1500$pred,reference = oneshot_gpt4_prompt1_1500$actual,mode = "prec_recall",positive = "1")