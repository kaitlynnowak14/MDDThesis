# ============================================================
# Title: Socioeconomic Status (SES) Distribution & Variability
# Dataset: All of Us Master Phenotype Dataset (master_final)
#
# Description:
#   - Summarizes distribution and variability of SES composite score
#   - Visualizes SES distribution using histogram
#   - Assesses variability of SES components (marital, education, employment)
#   - Examines correlations among SES components
#
# Outputs:
#   - SES summary statistics
#   - SES histogram plot
#   - SD estimates for SES components
#   - Correlation matrix of SES variables
#
# Notes:
#   - SES is scaled 0–1 composite score (ses_combined)
#   - Component SES variables are standardized (z-scaled 0–1)
# ============================================================

# =====================================================
# 0. LOAD PACKAGES
# =====================================================

library(dplyr)
library(ggplot2)

# =====================================================
# 1. SES DISTRIBUTION SUMMARY
# =====================================================

master_final %>%
  summarise(
    n = sum(!is.na(ses_combined)),
    mean = mean(ses_combined, na.rm = TRUE),
    sd = sd(ses_combined, na.rm = TRUE),
    var = var(ses_combined, na.rm = TRUE),
    min = min(ses_combined, na.rm = TRUE),
    max = max(ses_combined, na.rm = TRUE)
  )

# =====================================================
# 2. SES DISTRIBUTION VISUALIZATION
# =====================================================

ggplot(master_final, aes(x = ses_combined)) +
  geom_histogram(
    bins = 30,
    fill = col_AoU,
    alpha = 0.6,
    color = "white",
    linewidth = 0.3
  ) +
  labs(
    title = paste0(dataset_label, ": Distribution of Socioeconomic Status"),
    x = "Socioeconomic Status (0–1 Scaled)",
    y = "Count"
  ) +
  theme_thesis

# =====================================================
# 3. VARIABILITY OF SES COMPONENTS
# =====================================================

master_final %>%
  summarise(
    sd_marital = sd(marital_ses_std, na.rm = TRUE),
    sd_education = sd(education_ses_std, na.rm = TRUE),
    sd_employment = sd(employment_ses_std, na.rm = TRUE)
  )

# =====================================================
# 4. SES SUMMARY CHECK
# =====================================================

summary(master_final$ses_combined)
sd(master_final$ses_combined, na.rm = TRUE)

# =====================================================
# 5. CORRELATION MATRIX (SES COMPONENTS)
# =====================================================

cor(master_final[, c("marital_ses_std", "education_ses_std", "employment_ses_std", "ses_combined")],
    use = "complete.obs")
