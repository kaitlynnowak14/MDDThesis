# ============================================================================
# Title: PGRN-AMPS SES Distribution & Variability Analysis
# Dataset: PGRN-AMPS Cohort
#
# Description:
#   - Evaluate distribution and variability of SES composite scores
#   - Visualize SES distribution using histogram plots
#   - Examine variability of individual SES components
#   - Assess correlations among SES measures
#
# Output:
#   SES descriptive statistics
#   SES histogram visualization
#   SES component variability estimates
#   SES correlation matrix
#
# Notes:
#   - SES scores scaled from 0–1
#   - SES composite derived from marital, education,
#     and employment standardized measures
# ============================================================================

# =====================================================
# 1. LOAD PACKAGES
# =====================================================

library(dplyr)
library(ggplot2)

# =====================================================
# 2. SES DISTRIBUTION SUMMARY STATISTICS
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
# 3. SES DISTRIBUTION VISUALIZATION
# =====================================================

ggplot(master_final, aes(x = ses_combined)) +
  geom_histogram(
    bins = 30,
    fill = col_PGRN,
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
# 4. SES COMPONENT VARIABILITY
# =====================================================

master_final %>%
  summarise(
    sd_marital = sd(marital_ses_std, na.rm = TRUE),
    sd_education = sd(education_ses_std, na.rm = TRUE),
    sd_employment = sd(employment_ses_std, na.rm = TRUE)
  )

# =====================================================
# 5. SES COMPOSITE QUALITY CHECKS
# =====================================================

# Summary statistics 
summary(master_final$ses_combined)

# Standard deviation
sd(master_final$ses_combined, na.rm = TRUE)

# =====================================================
# 6. SES CORRELATION MATRIX
# =====================================================

cor(master_final[, c("marital_ses_std", "education_ses_std", "employment_ses_std", "ses_combined")],
    use = "complete.obs")
