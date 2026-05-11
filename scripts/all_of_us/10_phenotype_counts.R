# ============================================================
# Title: Phenotype Descriptive Statistics & Cohort Summary
# Dataset: All of Us Master Phenotype Dataset (master_final)
#
# Description:
#   - Generates demographic and SES summary statistics
#   - Produces distribution tables for key phenotype variables
#   - Prepares descriptive inputs for thesis tables (Table 1-style outputs)
#
# Outputs:
#   - sex_table
#   - marital_table
#   - education_table
#   - employment_table
#   - summary statistics (age, age of onset, SES)
#
# Notes:
#   - Uses cleaned dataset: master_final
#   - SES variables are ordinal-derived composite score (ses_combined)
# ============================================================

# =====================================================
# 0. LOAD PACKAGES
# =====================================================

library(dplyr)
library(snpStats)
library(data.table)
library(readr)
library(janitor)

# =====================================================
# 1. DEFINE INPUT DATASET
# =====================================================

phenos_clean <- master_final

# =====================================================
# 2. SEX DISTRIBUTION
# =====================================================

sex_table <- phenos_clean %>%
  tabyl(sex) %>%
  adorn_pct_formatting(digits = 1) # format percentages nicely

# =====================================================
# 3. AGE SUMMARY STATISTICS
# =====================================================

phenos_clean %>%
  summarise(
    mean_age = mean(age_at_survey, na.rm = TRUE),
    sd_age = sd(age_at_survey, na.rm = TRUE),
    mean_age_onset = mean(ageonset, na.rm = TRUE),
    sd_age_onset = sd(ageonset, na.rm = TRUE)
  )

# =====================================================
# 4. SOCIOECONOMIC STATUS (SES) DISTRIBUTIONS
# =====================================================

# Marital status
marital_table <- phenos_clean %>%
  tabyl(marital_ord) %>%
  adorn_pct_formatting(digits = 1)

# Education
education_table <- phenos_clean %>%
  tabyl(education_ord) %>%
  adorn_pct_formatting(digits = 1)

# Employment
employment_table <- phenos_clean %>%
  tabyl(employment_ord) %>%
  adorn_pct_formatting(digits = 1)

# =====================================================
# 5. COMPOSITE SES SUMMARY
# =====================================================

phenos_clean %>%
  summarise(
    mean_SES = mean(ses_combined, ma.rm = TRUE))
