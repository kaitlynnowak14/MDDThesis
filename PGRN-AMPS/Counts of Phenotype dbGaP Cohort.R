##### Counts of Phenotype dbGaP Cohort #####

library(dplyr)
library(snpStats)
library(data.table)
library(readr)
library(janitor)

# Set base & save paths for files
base_path <- "/Users/knowak/Desktop/PGRN-AMPS/Files Needed for Analyses"
save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"

# 1. Load phenotype files if not already done
phenos_clean <- read_csv(file.path(save_path, "PGRN_AMPS_Phenotypes_Clean.csv"))

# 2. Counts and percentages for gender
gender_table <- phenos_clean %>%
  tabyl(gender) %>%
  adorn_pct_formatting(digits = 1) # format percentages nicely

# 3. Mean age of onset and age
phenos_clean %>%
  summarise(
    mean_age = mean(age, na.rm = TRUE),
    sd_age = sd(age, na.rm = TRUE),
    mean_age_onset = mean(ageonset, na.rm = TRUE),
    sd_age_onset = sd(ageonset, na.rm = TRUE)
  )

# 4. Percent SES variables
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
