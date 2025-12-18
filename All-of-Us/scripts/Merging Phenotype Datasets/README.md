# Merge Phenotypes

This folder contains the script `Merge_Phenotypes.py` which merges multiple phenotype datasets from the **All of Us Researcher Program (Controlled Tier v8)** into a single consolidated dataset.

---

## Scripts Overview

| Script | Description | Dataset Focus |
|--------|-------------|----------------|
| `Merge_Phenotypes.py` | Merges person-level, survey, and condition occurrence datasets into a single dataframe (`merged_df`). Handles survey data cleaning, deduplication, pivoting, and saves the merged dataset to Google Cloud Storage. | Person-level demographics, survey responses, and condition occurrence dates |

---

## Usage Instructions

1. Ensure you are working within the **All of Us Controlled Tier secure environment**.
2. Load required DataFrames from prior queries and ensure variable names match those used in the script.
3. Set the `WORKSPACE_BUCKET` environment variable to your Google Cloud Storage bucket.
4. Run `Merge_Phenotypes.py` to generate `merged_df`.
5. Use `merged_df` as input for downstream scripts, such as creating age variables or Table 1 summaries.

---

## Output

- `all_of_us_merged_dataset.csv` saved to the workspace bucket.
- Quick inspection outputs displayed in the notebook, including participant counts and missing condition data.

---

These scripts standardize the merging of phenotype data to support consistent downstream analyses.
