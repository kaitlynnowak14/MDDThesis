# ============================================================
# Title: Sociodemographic Cohort Comparison
# Dataset:
#   - All of Us Cohort
#   - PGRN-AMPS Cohort
#
# Description:
#   - Create harmonized demographic subsets from both cohorts
#   - Merge datasets into a unified analytic dataframe
#   - Compare sociodemographic characteristics between cohorts
#   - Perform chi-square tests for categorical variables
#   - Perform Welch two-sample t-tests for continuous variables
#
# Variables:
#   Categorical:
#     - sex
#     - education_ord
#     - employment_ord
#     - marital_ord
#
#   Continuous:
#     - age
#     - ageonset
#     - ses_combined
#
# Output:
#   - combined_df
#   - chi-square test results
#   - Welch t-test results
#
# Notes:
#   - Harmonized variable naming required before merging
# ============================================================

# ============================================================
# 0. LOAD LIBRARIES
# ============================================================

library(dplyr)
library(data.table)

# ============================================================
# 1. CREATE ALL OF US ANALYTIC SUBSET
# ============================================================

# ---- Select & Harmonize Demographic Variables ----
subset_aou <- master_final %>%
  transmute(
    cohort = "All_of_Us",

    # Demographics
    sex,
    age = age_at_survey,
    ageonset,

    # SES Variables
    education_ord,
    employment_ord,
    marital_ord,
    
    ses_combined
  )

# ============================================================
# 2. LOAD PGRN-AMPS DEMOGRAPHIC SUBSET
# ============================================================

# ---- Copy Demographic File From Workspace Bucket ----
system("gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/demographic_subset.csv .")

# ---- Load PGRN-AMPS Dataset ----
subset_pgrn <- fread("demographic_subset.csv")

# ============================================================
# 3. MERGE COHORT DATASETS
# ============================================================

# ---- Combine Harmonized Datasets ----
combined_df <- bind_rows(subset_aou, subset_pgrn)

# ============================================================
# 4. CHI-SQUARE TESTS
# ============================================================

# ---- Sex Distribution ----
chisq.test(table(combined_df$cohort, combined_df$sex))

# ---- Education Distribution ----
chisq.test(table(combined_df$cohort, combined_df$education_ord))

# ---- Employment Distribution ----
chisq.test(table(combined_df$cohort, combined_df$employment_ord))

# ---- Marital Status Distribution ----
chisq.test(table(combined_df$cohort, combined_df$marital_ord))

# ============================================================
# 5. WELCH TWO-SAMPLE T-TESTS
# ============================================================

# ---- Age ----
t.test(age ~ cohort, data = combined_df)

# ---- Age of Onset ----
t.test(ageonset ~ cohort, data = combined_df)

# ---- Combined SES Score ----
t.test(ses_combined ~ cohort, data = combined_df)
