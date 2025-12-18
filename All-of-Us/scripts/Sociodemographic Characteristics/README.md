# Sociodemographic Characteristics

This folder contains the script `Sociodemographic_Characteristics.py` which generates a Table 1-style summary of sociodemographic characteristics for the merged **All of Us phenotype dataset**.

---

## Scripts Overview

| Script | Description | Variable Focus |
|--------|-------------|----------------|
| `Sociodemographic_Characteristics.py` | Generates a Table 1-style summary with counts and percentages for predefined sociodemographic categories. Collapses categories for reporting purposes and saves output to the workspace bucket. | Sex at Birth, Marital Status, Highest Educational Level, Employment Status |

---

## Usage Instructions

1. Ensure you are working within the **All of Us Controlled Tier secure environment**.
2. Set the `WORKSPACE_BUCKET` environment variable to your Google Cloud Storage bucket.
3. Make sure `merged_df` is loaded and contains the following columns:
   - `sex_at_birth`
   - `Current Marital Status`
   - `Highest Grade`
   - `Employment Status`
4. Run `Sociodemographic_Characteristics.py` to generate the Table 1 CSV.

---

## Output

- `table1_characteristics.csv` saved to the workspace bucket.
- Counts are formatted with commas for readability.
- Inline comments in the script explain each step of computation, formatting, and export.

---

This script standardizes sociodemographic summaries to support consistent reporting across analyses.
