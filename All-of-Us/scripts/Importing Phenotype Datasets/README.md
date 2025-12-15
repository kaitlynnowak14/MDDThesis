# Phenotype Dataset Scripts

This folder contains Python scrips to import and qiery phenotype datasets from the **All of Us Research Program (Controlled Tier v8)**. Each script is designed for a specific domain and pre-selected European ancestry cohort.

**Important:** Do **not** modify these scripts. They are intended to be run as-is in the All of Us secure cloud environment.

---

## Scripts Overview
| Script | Description | Dataset Focus |
| `Survey_Phnotypes.py` | Queries survey answers and survey datetime information for selected variables in the European ancestry cohort. | Survey answers and survey datetime |
| `Person_Phenotypes.py` | Retrieves basic person-level phenotypes such as date of birth and sex at birth for the cohort. | Person-level demographics |
| `Conditon_Phenotypes.py` | Retrieves condition occurrence dates for the cohort. | Conditoon occurrence dates |

---

## Usage Instructions

1. Make sure you are working with the **All of Us Controleld Tier secure environment**.
2. Create specific cohort intenting to work with.
3. Create dataset selecting specific cohort and variables intenting to work with.
