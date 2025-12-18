# Coding Variables & Hail Conversion

This folder contains the script to code sociodemographic variables, compute scaled and standardized scores,
generate summary statistics and plots, and convert the merged All of Us phenotype dataset
into a Hail Table for downstream genomic analyses.

---

## Script Overview

| Script | Description | Output Focus |
|--------|-------------|--------------|
| `Coding_Variables_Hail_Conversion.py` | Codes sociodemographic variables, calculates scaled and Z-standardized scores, computes a composite SES score, generates histograms and summary statistics, and converts the dataset into a Hail Table. | Coded variables, scaled variables, standardized variables, SES scores, summary statistics, plots, Hail Table |

---

## Usage Instructions

1. Ensure you are working within the **All of Us Controlled Tier secure environment**.
2. Set the `WORKSPACE_BUCKET` environment variable to your Google Cloud Storage bucket.
3. Make sure `merged_df` is loaded and contains required columns:
   - `sex_at_birth`
   - `Highest Grade`
   - `Employment Status`
   - `Current Marital Status`
   - `person_id`
4. Run the script to generate coded variables, scaled and standardized scores, plots, summary statistics, and the Hail Table.

---

## Output

- CSV files with:
  - Coded variables (`all_of_us_coded_variables.csv`)
  - Final dataset with all coded/scaled/Z variables (`all_of_us_final_dataset.csv`)
  - Summary statistics for scaled variables (`summary_scaled_variables.csv`)
  - Summary statistics for standardized variables (`summary_standardized_variables.csv`)
- Histograms of scaled and standardized variables (`scaled_variables_histograms.png` and `standardized_variables_histograms.png`)
- Hail Table (`ht_pheno`) ready for annotation of Hail MatrixTables

---

These outputs standardize sociodemographic coding and SES scoring to ensure consistency for downstream analyses and genomic annotation.
