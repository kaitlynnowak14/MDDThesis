##### MA Analyses #####

# 1. INSERT LOADING PACKAGES + FILES IF NEEDED ####
## This was already done when I ran this, since I did EA before

# ================================== MA Models ====================================

# 0. Covariates Only ####
MA_model_cov <- lm(ageonset ~ pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                     pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                data = master_final)

summary(MA_model_cov)

# 1. PRS Only ####
MA_model_prs <- lm(ageonset ~ MA_PRS_z +
                     pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                     pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                data = master_final)

summary(MA_model_prs)

# 2. Sex Only ####
MA_model_sex <- lm(ageonset ~ sex +
                     pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                     pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                data = master_final)

summary(MA_model_sex)

# 3. SES Only ####
MA_model_ses <- lm(ageonset ~ ses_combined +
                     pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                     pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                data = master_final)

summary(MA_model_ses)

# 4. Additive Model (no interactions) ####
MA_model_additive <- lm(ageonset ~ MA_PRS_z + sex + ses_combined +
                          pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                          pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                     data = master_final)

summary(MA_model_additive)

# 5. PRS x Sex Interaction ####
MA_model_prs_sex <- lm(ageonset ~ MA_PRS_z * sex +
                      ses_combined +
                        pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                        pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                    data = master_final)

summary(MA_model_prs_sex)

# 6. PRS x SES Interaction ####
MA_model_prs_ses <- lm(ageonset ~ MA_PRS_z * ses_combined +
                      sex +
                        pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                        pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                    data = master_final)

summary(MA_model_prs_ses)

# 7. Sex x SES Interaction ####
MA_model_sex_ses <- lm(ageonset ~ sex * ses_combined +
                      MA_PRS_z +
                        pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                        pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                    data = master_final)

summary(MA_model_sex_ses)

# 8. Full 2-Way Interaction Model ####
MA_model_full_2way <- lm(ageonset ~ MA_PRS_z * sex +
                        MA_PRS_z * ses_combined +
                        sex * ses_combined +
                          pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                          pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                      data = master_final)

summary(MA_model_full_2way)

# 9. Full 3-Way Interaction Model ####
MA_model_full_3way <- lm(ageonset ~ MA_PRS_z * sex * ses_combined +
                           pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                           pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                      data = master_final)

summary(MA_model_full_3way)

# ======================== Comparing Models ====================================

# 1. Main effects likelihood ratio test (LRT)
anova(MA_model_cov, MA_model_prs) 
anova(MA_model_cov, MA_model_sex)
anova(MA_model_cov, MA_model_ses)
anova(MA_model_prs, MA_model_additive)

# 2. Interaction terms LRT
anova(MA_model_additive, MA_model_prs_sex)
anova(MA_model_additive, MA_model_prs_ses)
anova(MA_model_additive, MA_model_sex_ses)

# 3. Higher-order models LRT
anova(MA_model_additive, MA_model_full_2way)
anova(MA_model_full_2way, MA_model_full_3way)

# 4. Akaike Information Criterion (AIC) model comparison (lower AIC = better model)
AIC(MA_model_cov, MA_model_prs, MA_model_additive, MA_model_full_2way, MA_model_full_3way)

AIC(MA_model_additive, MA_model_prs_sex, MA_model_prs_ses, MA_model_sex_ses, MA_model_full_2way)

# 5. Bayesian Information Criterion (BIC) model comparison
BIC(MA_model_cov, MA_model_prs, MA_model_additive, MA_model_full_2way, MA_model_full_3way)

BIC(MA_model_additive, MA_model_prs_sex, MA_model_prs_ses, MA_model_sex_ses, MA_model_full_2way)

# 6. Root Mean Squared Error (RMSE) (measured prediciton error)
rmse <- function(model) {
  sqrt(mean(residuals(model)^2))
}

MA_rmse_values <- data.frame(
  Model = c("Covariates", "PRS", "Additive", "Full 2-way", "Full 3-way"),
  RMSE = c(
    rmse(MA_model_cov),
    rmse(MA_model_prs),
    rmse(MA_model_additive),
    rmse(MA_model_full_2way),
    rmse(MA_model_full_3way)
  )
)

MA_rmse_values

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

# 1. Figure 1: EA PRS & Age of Onset ####
MA_model_prs_simple <- lm(ageonset ~ MA_PRS_z, data = master_final)
MA_r2_prs <- summary(MA_model_prs_simple)$r.squared

ggplot(master_final, aes(x = MA_PRS_z, y = ageonset)) +
  geom_point(alpha = 0.5, size = 1.5, color = col_MA) +
  geom_smooth(method = "lm", se = TRUE, color = col_other, linewidth = 1.2) +
  annotate("text",
           x = Inf, y = -Inf,
           label = paste0("R² = ", round(MA_r2_prs, 3)),
           hjust = 1.1, vjust = -0.8, size = 4) +
  labs(
    title = paste0(dataset_label, ": MA Polygenic Risk Score and Age of MDD Onset"),
    x = "MA Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis

# 2. Figure 2: SES & Age of Onset ####
MA_model_ses_simple <- lm(ageonset ~ ses_combined, data = master_final)
MA_r2_ses <- summary(MA_model_ses_simple)$r.squared

ggplot(master_final, aes(x = ses_combined, y = ageonset)) +
  geom_point(alpha = 0.5, size = 1.5, color = col_other) +
  geom_smooth(method = "lm", se = TRUE, color = col_other, linewidth = 1.2) +
  annotate("text",
           x = Inf, y = -Inf,
           label = paste0("R² = ", round(MA_r2_ses, 3)),
           hjust = 1.1, vjust = -0.8, size = 4) +
  labs(
    title = paste0(dataset_label, ": Socioeconomic Status and Age of MDD Onset"),
    x = "Socioeconomic Status (0–1 Scaled)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis

# 3. Figure 3: Sex Differences
ggplot(master_final, aes(x = sex, y = ageonset)) +
  geom_boxplot(fill = col_other, alpha = 0.6, linewidth = 1) +
  labs(
    title = paste0(dataset_label, ": Sex Differences in Age of MDD Onset"),
    x = "Sex",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis

# 4. Figure 4: Sex x SES Interaction
MA_model_sex_ses <- lm(ageonset ~ sex * ses_combined +
                      MA_PRS_z + pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                        pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                    data = master_final)

MA_newdata <- expand.grid(
  ses_combined = seq(min(master_final$ses_combined, na.rm = TRUE),
                     max(master_final$ses_combined, na.rm = TRUE),
                     length.out = 100),
  sex = unique(master_final$sex),
  MA_PRS_z = 0,
  pc_1 = 0, pc_2 = 0, pc_3 = 0, pc_4 = 0, pc_5 = 0,  pc_6 = 0, pc_7 = 0,  pc_8 = 0,
  pc_9 = 0, pc_10 = 0, pc_11 = 0, pc_12 = 0, pc_13 = 0, pc_14 = 0, pc_15 = 0, pc_16 = 0
)

MA_pred <- predict(MA_model_sex_ses, MA_newdata, se.fit = TRUE)
MA_newdata$fit <- MA_pred$fit
MA_newdata$lower <- MA_pred$fit - 1.96 * MA_pred$se.fit
MA_newdata$upper <- MA_pred$fit + 1.96 * MA_pred$se.fit

ggplot(MA_newdata, aes(x = ses_combined, y = fit, color = sex, fill = sex)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.15, color = NA) +
  geom_line(linewidth = 1.3) +
  
  scale_color_manual(values = c(
    "Male" = col_male,
    "Female" = col_female
  )) +
  scale_fill_manual(values = c(
    "Male" = col_male,
    "Female" = col_female
  )) +
  
  labs(
    title = paste0(dataset_label, ": Sex × Socioeconomic Status Interaction on Age of MDD Onset"),
    x = "Socioeconomic Status (0–1 scaled)",
    y = "Predicted Age of MDD Onset (Years)",
    color = "Sex",
    fill = "Sex"
  ) +
  theme_thesis

# 5. Figure 5: EA PRS x Sex
ggplot(master_final, aes(x = MA_PRS_z, y = ageonset)) +
  
  # MA PRS distribution (background signal)
  geom_point(alpha = 0.4, color = col_MA) +
  
  # sex-specific fitted lines
  geom_smooth(aes(color = sex), method = "lm", se = FALSE, linewidth = 1.2) +
  
  scale_color_manual(values = c(
    "Male" = col_male,
    "Female" = col_female
  )) +
  
  labs(
    title = paste0(dataset_label, ": MA PRS × Sex Interaction on Age of MDD Onset"),
    x = "MA Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)",
    color = "Sex"
  ) +
  
  theme_thesis

# Figure 6: MA PRS x SES ####
# Grouping already run!!
# master_final$ses_group <- ifelse(
#  master_final$ses_combined >= median(master_final$ses_combined, na.rm = TRUE),
#  "Higher SES",
#  "Lower SES"
# )

ggplot(master_final, aes(x = MA_PRS_z, y = ageonset)) +
  
  geom_point(alpha = 0.35, color = col_MA) +
  
  geom_smooth(
    aes(color = ses_group),
    method = "lm",
    se = FALSE,
    linewidth = 1.2
  ) +
  
  scale_color_manual(values = c(
    "Lower SES" = col_other,
    "Higher SES" = "grey30"
  )) +
  
  labs(
    title = paste0(dataset_label, ": MA PRS × SES Stratified Association on Age of MDD Onset"),
    x = "MA Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)",
    color = "SES Group"
  ) +
  
  theme_thesis
