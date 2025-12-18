# Coding Variables & Hail Conversion

This folder contains the script `Coding_Variables_Hail_Conversion.py` which codes sociodemographic variables, computes scaled and standardized scores, and converts the merged phenotype dataset into a **Hail Table** for downstream genomic analyses.

---

## Script Overview

| Script | Description | Output Focus |
|--------|-------------|---------------|
| `Coding_Variables_Hail_Conversion.py` | Codes variables for sex, education, employment, and marital status; computes scaled and Z-scores; creates composite SES score; generates plots and summary statistics; converts to Hail Table. | Binary/coded variables, scaled variables, standardized Z-scores, SES composite, Hail Table for downstream analyses |

---

## Usage Instructions

1. Ensure you are working within the **All of Us Controlled Tier secure environment**.
2. Set the `WORKSPACE_BUCKET` environment variable to your Google Cloud Storage bucket.
3. Make sure `merged_df` is loaded and contains the following columns:
   - `sex_at_birth`
   - `Highest Grade`
   - `Employment Status`
   - `Current Marital Status`
4. Run the script to generate:
   - Coded, scaled, and standardized variables
   - Plots of distributions for scaled and standardized scores
   - Summary statistics CSVs for scaled and standardized variables
   - Hail Table (`ht_pheno`) for downstream genomic analyses

---

## Output

- `all_of_us_coded_variables.csv`: Merged dataset with coded variables.
- `scaled_variables_histograms.png`: Histograms and KDEs of scaled scores.
- `standardized_variables_histograms.png`: Histograms and KDEs of Z-scores.
- `all_of_us_final_dataset.csv`: Dataset with all coded, scaled, and standardized variables.
- `summary_scaled_variables.csv`: Summary statistics for scaled variables.
- `summary_standardized_variables.csv`: Summary statistics for standardized variables.
- Hail Table (`ht_pheno`) annotated from pandas DataFrame.

---

This script standardizes sociodemographic variable coding, scaling, and transformation for consistent downstream analyses, including integration with Hail for genomic workflows.
