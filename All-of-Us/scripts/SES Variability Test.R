# SES distribution and variability

library(dplyr)
library(ggplot2)

# Check SES distribution
master_final %>%
  summarise(
    n = sum(!is.na(ses_combined)),
    mean = mean(ses_combined, na.rm = TRUE),
    sd = sd(ses_combined, na.rm = TRUE),
    var = var(ses_combined, na.rm = TRUE),
    min = min(ses_combined, na.rm = TRUE),
    max = max(ses_combined, na.rm = TRUE)
  )

# Visualize SES distribution
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

master_final %>%
  summarise(
    sd_marital = sd(marital_ses_std, na.rm = TRUE),
    sd_education = sd(education_ses_std, na.rm = TRUE),
    sd_employment = sd(employment_ses_std, na.rm = TRUE)
  )

# Check individual correlation
summary(master_final$ses_combined)
sd(master_final$ses_combined, na.rm = TRUE)

cor(master_final[, c("marital_ses_std", "education_ses_std", "employment_ses_std", "ses_combined")],
    use = "complete.obs")
