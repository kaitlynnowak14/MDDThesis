# Creating Age Variables

This folder contains Python scripts to generate age-related variables for the **All of Us phenotype dataset**. Each script calculates a specific age variable and generates summary outputs for analysis.

---

## Scripts Overview

| Script | Description | Variable Focus |
|--------|-------------|----------------|
| `Age_of_Onset.py` | Calculates Age of Onset (AoO) for Major Depressive Disorder. Produces descriptive statistics, histograms, Q–Q plots, normality tests, candidate transformations, and sex-stratified summaries. | Age of Onset (years at condition start) |
| `Age_at_Survey.py` | Calculates Age at Survey for each participant. Produces descriptive statistics and histogram. | Age at Survey (years at survey date) |

---

## Usage Instructions

1. Ensure you are working within the **All of Us Controlled Tier secure environment**.
2. Set the `WORKSPACE_BUCKET` environment variable to your Google Cloud Storage bucket.
3. Make sure `merged_df` is loaded and contains required columns:
   - `date_of_birth`
   - `condition_start_datetime` (for `Age_of_Onset.py`)
   - `survey_datetime` (for `Age_at_Survey.py`)
4. Run each script individually as needed to generate age variables and output files.

---

## Output

- CSV files with age variables and summary statistics.
- Histograms of distributions saved as PNG files to the GCS bucket.
- Scripts include inline comments explaining each step of computation, visualization, and export.

---

These scripts standardize age variable creation to support consistent downstream analyses.
