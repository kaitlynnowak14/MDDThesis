
# 0. Load packages & set paths ####
library(data.table)
library(dplyr)
library(ggplot2)

# 1. Load files ####
system("gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/final_merged_dataset.csv .")

master_final <- fread("final_merged_dataset.csv")

# 2. SES score & clean dataset ####
# SES combined score creation
min_max <- function(x) {
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}

master_final$marital_ses_std   <- min_max(master_final$marital_ord)
master_final$education_ses_std <- min_max(master_final$education_ord)
master_final$employment_ses_std <- min_max(master_final$employment_ord)

master_final$ses_combined_raw <-
  master_final$marital_ses_std +
  master_final$education_ses_std +
  master_final$employment_ses_std

master_final$ses_combined <- min_max(master_final$ses_combined_raw)

# Clean up naming
master_final <- master_final %>%
  rename(
    ageonset = age_of_onset,   # age of onset
    sex = sex_at_birth,          # rename sex column
  )

# 3. Descriptive statistics for age of onset ####
mean_age <- mean(master_final$ageonset, na.rm = TRUE)
sd_age   <- sd(master_final$ageonset, na.rm = TRUE)

cat("Age of onset:", round(mean_age,1), "±", round(sd_age,1), "years\n")

# Histogram
col_other <- "grey60"

hist(master_final$ageonset,
     breaks = 20,
     xlab = "Age of Onset (Years)",
     main = "All of Us: Distribution of Age of Onset",
     col = col_other,
     border = "white")

# 4. Fix sex reference group
master_final$sex <- factor(master_final$sex,
                           levels = c("Male", "Female"))

# ================================== EA Models ====================================

# 0. Covariates Only ####
model_cov <- lm(ageonset ~ pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                  pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                data = master_final)

summary(model_cov)

# 1. PRS Only ####
model_prs <- lm(ageonset ~ EA_PRS_z +
                  pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                  pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                data = master_final)

summary(model_prs)

# 2. Sex Only ####
model_sex <- lm(ageonset ~ sex +
                  pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                  pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                data = master_final)

summary(model_sex)

# 3. SES Only ####
model_ses <- lm(ageonset ~ ses_combined +
                  pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                  pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                data = master_final)

summary(model_ses)

# 4. Additive Model (no interactions) ####
model_additive <- lm(ageonset ~ EA_PRS_z + sex + ses_combined +
                       pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                       pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                     data = master_final)

summary(model_additive)

# ======================== Comparing Models ====================================

# 1. Main effects likelihood ratio test (LRT)
anova(model_cov, model_additive)
anova(model_prs, model_additive)
anova(model_sex, model_additive)
anova(model_ses, model_additive)

# 4. Akaike Information Criterion (AIC) model comparison (lower AIC = better model)
AIC(model_cov, model_prs, model_sex, model_ses, model_additive)

# ======================== Creating Figures ====================================

# 0. Set Theme
# PRS / ancestry colors (PRIMARY COMPARISON)
col_EA <- "steelblue"
col_MA <- "#B22222"

# Covariates / non-primary grouping
col_other <- "grey60"

# Sex (secondary grouping — keep neutral)
col_male <- "grey30"
col_female <- "grey70"

# Dataset label
dataset_label <- "All of Us"

# Global theme
theme_thesis <- theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.line = element_line(linewidth = 0.8)
  )

# 1. Figure 1: EA PRS (Unadjusted) ####
model_prs_simple <- lm(ageonset ~ EA_PRS_z, data = master_final)
r2_prs <- summary(model_prs_simple)$r.squared

fig1 <- ggplot(master_final, aes(x = EA_PRS_z, y = ageonset)) +
  geom_point(alpha = 0.5, size = 1.5, color = col_EA) +
  geom_smooth(method = "lm", se = TRUE, color = col_EA, linewidth = 1.2) +
  annotate("text",
           x = Inf, y = -Inf,
           label = paste0("R² = ", round(r2_prs, 4)),
           hjust = 1.1, vjust = -0.8, size = 4) +
  labs(
    title = paste0(dataset_label, ": EA PRS and Age of MDD Onset (Unadjusted)"),
    x = "EA Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis

print(fig1)

# 2. Figure 2: SES & Age of Onset ####
model_ses_simple <- lm(ageonset ~ ses_combined, data = master_final)
r2_ses <- summary(model_ses_simple)$r.squared

fig2 <- ggplot(master_final, aes(x = ses_combined, y = ageonset)) +
  geom_point(alpha = 0.5, size = 1.5, color = col_other) +
  geom_smooth(method = "lm", se = TRUE, color = col_other, linewidth = 1.2) +
  annotate("text",
           x = Inf, y = -Inf,
           label = paste0("R² = ", round(r2_ses, 3)),
           hjust = 1.1, vjust = -0.8, size = 4) +
  labs(
    title = paste0(dataset_label, ": SES and Age of MDD Onset (Unadjusted)"),
    x = "Socioeconomic Status (0–1 Scaled)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis

print(fig2)

# 3. Figure 3: Sex Differences
fig3 <- ggplot(master_final, aes(x = sex, y = ageonset)) +
  geom_boxplot(fill = col_other, alpha = 0.6, linewidth = 1) +
  labs(
    title = paste0(dataset_label, ": Sex Differences in Age of MDD Onset"),
    x = "Sex",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis

print(fig3)

# 4.  Figure 4: Main Effects Model Visualization
library(ggeffects)

prs_effect <- ggpredict(model_additive, terms = "EA_PRS_z")
prs_df <- as.data.frame(prs_effect)

fig4 <- ggplot(prs_df, aes(x = x, y = predicted)) +
  geom_line(color = col_EA, linewidth = 1.2) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high),
              fill = col_EA, alpha = 0.2) +
  labs(
    title = paste0(dataset_label, ": Adjusted Effect of EA PRS on Age of MDD Onset"),
    x = "EA Polygenic Risk Score (Z)",
    y = "Predicted Age of Onset"
  ) +
  theme_thesis

print(fig4)

# 5. Figure 5: Model Comparison
model_r2 <- data.frame(
  Model = c("Covariates", "PRS", "Sex", "SES", "Additive"),
  R2 = c(0.0373, 0.03774, 0.04109, 0.04881, 0.05115)
)

fig5 <- ggplot(model_r2, aes(x = Model, y = R2)) +
  geom_col(fill = "grey50") +
  labs(
    title = paste0(dataset_label, ": EA Model R² Comparison"),
    x = "EA Model",
    y = "EA R²"
  ) +
  theme_thesis

print(fig5)
