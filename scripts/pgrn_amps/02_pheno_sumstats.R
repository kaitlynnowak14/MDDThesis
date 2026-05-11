# ============================================================
# Title: Phenotype Summary Statistics (PGRN-AMPS Cohort)
# Dataset: Cleaned dbGaP Phenotypes
#
# Description:
#   - Generates cohort descriptive statistics
#   - Compute gender distribution
#   - Selecys analytic variables
#   - Summarizes age and age of osnet
#   - Explores SES-related categorical variables
#
# Output:
#   PGRN_AMPS_Phenotypes_clean.csv
#
# Notes: 
#   - Ensures harmonized and analytic cohort for PRS + phenotype models
#   - Removes "Other" race and unknown marital status ("U")
# =============================================================

# =====================================================
# 1. LOAD LIBRARIES & DATA
# =====================================================

library(dplyr)
library(snpStats)
library(data.table)
library(readr)
library(janitor)

base_path <- "/Users/knowak/Desktop/PGRN-AMPS/Files Needed for Analyses"
save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"

phenos_clean <- read_csv(file.path(save_path, "PGRN_AMPS_Phenotypes_Clean.csv"))

# =====================================================
# 2. GENDER DISTRIBUTION
# =====================================================
gender_table <- phenos_clean %>%
  tabyl(gender) %>%
  adorn_pct_formatting(digits = 1) # format percentages nicely

# =====================================================
# 3. AGE SUMMARY STATISTICS
# =====================================================
phenos_clean %>%
  summarise(
    mean_age = mean(age, na.rm = TRUE),
    sd_age = sd(age, na.rm = TRUE),
    mean_age_onset = mean(ageonset, na.rm = TRUE),
    sd_age_onset = sd(ageonset, na.rm = TRUE)
  )

# =====================================================
#4. SES-RELATED DISTRIBUTIONS
# =====================================================
# Marital status
marital_table <- phenos_clean %>%
  tabyl(maritalstatus) %>%
  adorn_pct_formatting(digits = 1)

# Education
education_table <- phenos_clean %>%
  tabyl(highdegree) %>%
  adorn_pct_formatting(digits = 1)

# Employment
employment_table <- phenos_clean %>%
  tabyl(currentempstat) %>%
  adorn_pct_formatting(digits = 1)
