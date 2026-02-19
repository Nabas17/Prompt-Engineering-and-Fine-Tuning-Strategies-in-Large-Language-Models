# Metastatic Cancer Classification Using LLMs  
**AMIA 2024 Reproducible README**

## Paper
**Comparison of Prompt Engineering and Fine-Tuning Strategies in Large Language Models**  
AMIA Annual Symposium 2024

---

## Project Summary
This repository contains R code to evaluate **prompt engineering strategies** in large language models (LLMs) for identifying **metastatic cancer** from clinical discharge summaries.

The study investigates whether carefully designed prompts can achieve strong clinical NLP performance without model fine-tuning.

---

## Task Definition
**Input:** Clinical discharge summary text  
**Output:** Binary classification

| Label | Meaning |
|------|--------|
| Yes | Metastatic cancer present |
| No | Metastatic cancer absent |

---

## Dataset
Dataset contains:
- `TEXT` → discharge summary
- `Advanced.Cancer` → ground truth label

For experiments, subsets (e.g., first 200 notes) are used to control cost and runtime.

> Clinical data not included due to privacy restrictions.

---

## Experimental Design

### Prompt Strategy
One-shot prompting with:
- Healthcare professional role instruction
- Step-by-step reasoning guidance
- Example-based demonstration

### Pipeline
1. Load clinical notes
2. Subset dataset
3. Truncate text (token control)
4. Construct prompt messages
5. Query OpenAI API
6. Extract predictions
7. Convert predictions to binary labels
8. Compute evaluation metrics

---

## Experiment Table

| Experiment ID | Model | Prompt Type | Max Input Length | Temperature |
|---------------|------|-------------|------------------|-------------|
| E1 | GPT-3.5 | One-shot | 1500 chars | 0.2 |
| E2 | GPT-4 | One-shot | 1500 chars | 0.2 |
| E3 | GPT-4 | One-shot + reasoning | 1500 chars | 0.2 |

---

## Results

### Performance Metrics
Evaluation performed using confusion matrix:

- Precision
- Recall
- F1 score
- Accuracy

---

Example evaluation code:
```r
confusionMatrix(data=pred, reference=actual, mode="prec_recall", positive="1")
```
---

### Repositary Structure
├── mci_test_allgpt.R
├── one_shot_gpt3.5_all_promt.R
├── one_shot_gpt4_all_promt.R
└── README.md

---

### Citation

If you use this repository, please cite:

Comparison of Prompt Engineering and Fine-Tuning Strategies in Large Language Models
AMIA Annual Symposium, 2024
