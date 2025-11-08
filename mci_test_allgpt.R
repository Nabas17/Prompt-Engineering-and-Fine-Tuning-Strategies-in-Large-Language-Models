#To compare the GPT-4 on test data we will run the mci_test data on all the prompts for 1500 , 3000 input size  

# Install packages
install.packages(c("httr", "stringr","jasonlite","openai"))

# Load Libraries
library(httr)
library(stringr)
library(readxl)
library(jsonlite)
library(openai)

# establish the connection between R and our chatGPT account, attach the api here
gpt_api <- "Add your gpt API"

# for comparison with fine-tune model, add your test data file 
cancer_data <- read.csv("mci_test_data.csv")
n <- nrow(cancer_data)
head(cancer_data,10)

#Sometimes the interface don't process the whole data and we might get trancuated data and hence better to run for small subset first
cancer_new<-cancer_data[1:n,]
input <- cancer_new$text

# Common instruction to be followed for all messages: run each prompt one-by-one

#Prompt 0
common_instruction <- "Please act as a curator. Based on the input discharge summary, classify if the patient has MCI or not.please provide a concise response as either 'Yes' or ‘No'"

#Prompt 1
common_instruction <- "This is a discharge summary for a patient who underwent diagnostic tests, please act as a healthcare professional and classify if the patients has mci or not using following steps:
1.Identify if patient has mci or not.
2.Based on the information please provide a concise response as either 'Yes' or ‘No'."

#Prompt 2
common_instruction <-"This is a discharge summary for a patient who recently underwent diagnostic tests. 
Please analyze the following information and provide a concise response as either 'Yes' or 'No' based on the presence of mild cognitive impairment in the patient's discharge summary.
mild cognitive impairment is different from dementia or Alzermier's."

#Prompt 3
common_instruction <- "This is a discharge summary for a patient. Please act as a healthcare professional and provide a response based on the summary using the following instructions:
1. Identify if patient has mild cognitive impairment(MCI) or not.
2. If there is clear evidence respond 'Yes' or 'No'
3. Remember that mild cognitive impairment (MCI) is a condition in which someone has minor problems with cognition - 
their mental abilities such as memory or thinking."

#Prompt 4
common_instruction <- "Please act as a curator and analyze the following discharge summary, classify if the patient has mild cognitive impairment(MCI)  or not. Let's think step by step. Choose the final answer from the list {Yes, No}"

#new prompt 5
common_instruction <- "As a healthcare professional, please analyze the following discharge summary and determine if the patient has mild cognitive impairment. Please provide a concise 'Yes' or 'No' response"

#new_prompt 6
common_instruction <- "Respond to the discharge summary by following these instructions as a healthcare professional:
1. Determine whether the patient has mild cognitive impairment (MCI).
2. Respond 'Yes' if there is clear evidence.
3. In case of doubt or ambiguity, answer 'no'"

#New_prompt 7
common_instruction <- "As a clinical data interpreter your duty is to analyze each discharge summary and determine whether or not the patient has mild cognitive impairment. Please follow the following guidelines:
Assign 'Yes' if the summary clearly indicates the presence of has mild cognitive impairment.
Assign 'No' if there is no clear evidence of the presence of has mild cognitive impairment.
Assign 'Unsure' if there isn't enough information to confirm or disprove."

#prompt 7 without unsure
common_instruction <- "As a clinical data interpreter your duty is to analyze each discharge summary and determine whether or not the patient has mild cognitive impairment. Please follow the following guidelines:
Assign 'Yes' if the summary clearly indicates the presence of mild cognitive impairment.
Assign 'No' if there is no clear evidence of the presence of has mild cognitive impairment.
Ensure the responses are clearly within 'Yes' and 'No'."

#Prompt 8
common_instruction <- "As a neurologist, it's your duty to analyze each discharge summary and determine whether a patient has mild cognitive impairment. Those with mild cognitive impairment (MCI) have minor problems with their cognition - their mental abilities such as memory, thinking, or learning. This is not the same as dementia or Alzermier's disease. Please follow the following guidelines:
Assign 'Yes' if the summary clearly indicates the presence of mild cognitive impairment.
Assign 'No' if there is no clear evidence of the presence of has mild cognitive impairment.
Let's think step by step , and ensure the responses are clearly within 'Yes' and 'No'"

#prompt 5 (additional)
common_instruction <- "As a healthcare professional, please analyze the following discharge summary and determine if the patient has mild cognitive impairment. Take a deep breath and think step by step.Please provide a concise 'Yes' or 'No' response" 

## Initialize an empty character vector
response1 <- character(0)
response2 <- character(0)
pred <- NULL
pred_new <- NULL

# Create a list of messages with the common questions, and instructions
question <- list(list(role = "assistant", content = common_instruction))

# Input size run for (1500,3000)

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
      model = "gpt-3.5-turbo-0301", # Use gpt-3.5 is very fast
      messages = messages,
      temperature=0.2,max_tokens=30
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
  
  response_new <- ifelse(sapply("no", function(word) grepl(word,tolower(answer_gpt1))) > 0,0,1)
  pred_new<-c(pred_new,response_new)
} 

# store in a data frame each of the data_frame generated from running the dataset 
pred <- as.factor(pred)
n <- length(pred)
pred_new <- as.factor(pred_new)
n <- length(pred_new)

#depending on the length of pred choose only those rows
actual <- as.factor(cancer_new$label[1:n])
input <- input[1:n]

#depending on how many times the same dataset has been runed store it in a data frame names with r1,r2 so on..
data_gpt3.5_r5a <- data.frame(actual,pred,pred_new,response1,input)

#combine all r1,r2... and rename the final dataset based on your combination , for eg gpt4, input size 1500, prompt0 
data_gpt3.5_r2 <- rbind(data_gpt3.5_r2,data_gpt3.5_r2a)

#Confusion Matrix
library(caret)
confusionMatrix(data=data_gpt3.5_r5a$pred,reference = data_gpt3.5_r5a$actual,mode = "prec_recall",positive = "1")

##### No need to convert to json format
#convert the data into Jason format(remove inout and response1 response2)
jsonData <- toJSON(test_data_r3, pretty = TRUE)
write(jsonData, "output.json")
