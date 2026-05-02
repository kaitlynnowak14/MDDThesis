##### Counts of Phenotype Variables #####

library(dplyr)
library(snpStats)
library(data.table)
library(readr)
library(janitor)

# 1. Load phenotype files if not already done
phenos_clean <- master_final

# 2. Counts and percentages for gender
sex_table <- phenos_clean %>%
  tabyl(sex) %>%
  adorn_pct_formatting(digits = 1) # format percentages nicely

# 3. Mean age of onset and age
phenos_clean %>%
  summarise(
    mean_age = mean(age_at_survey, na.rm = TRUE),
    sd_age = sd(age_at_survey, na.rm = TRUE),
    mean_age_onset = mean(ageonset, na.rm = TRUE),
    sd_age_onset = sd(ageonset, na.rm = TRUE)
  )

# 4. Percent SES variables
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

# 5. Mean SES 
phenos_clean %>%
  summarise(
    mean_SES = mean(ses_combined, ma.rm = TRUE))
