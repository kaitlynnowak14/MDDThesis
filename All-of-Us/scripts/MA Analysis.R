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

# ======================== Comparing Models ====================================

# 1. Main effects likelihood ratio test (LRT)
anova(MA_model_cov, MA_model_additive)
anova(MA_model_prs, MA_model_additive)
anova(MA_model_sex, MA_model_additive)
anova(MA_model_ses, MA_model_additive)

# 4. Akaike Information Criterion (AIC) model comparison (lower AIC = better model)
AIC(MA_model_cov, MA_model_prs, MA_model_sex, MA_model_ses, MA_model_additive)

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

# 1. Figure 1: MA PRS (Unadjusted) ####
MA_model_prs_simple <- lm(ageonset ~ MA_PRS_z, data = master_final)
MA_r2_prs <- summary(MA_model_prs_simple)$r.squared

MA_fig1 <- ggplot(master_final, aes(x = MA_PRS_z, y = ageonset)) +
  geom_point(alpha = 0.5, size = 1.5, color = col_MA) +
  geom_smooth(method = "lm", se = TRUE, color = col_MA, linewidth = 1.2) +
  annotate("text",
           x = Inf, y = -Inf,
           label = paste0("R² = ", round(MA_r2_prs, 3)),
           hjust = 1.1, vjust = -0.8, size = 4) +
  labs(
    title = paste0(dataset_label, ": MA PRS and Age of MDD Onset (Unadjusted)"),
    x = "MA Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis

print(MA_fig1)

# 2. Figure 2: SES & Age of Onset ####
MA_model_ses_simple <- lm(ageonset ~ ses_combined, data = master_final)
MA_r2_ses <- summary(MA_model_ses_simple)$r.squared

MA_fig2 <- ggplot(master_final, aes(x = ses_combined, y = ageonset)) +
  geom_point(alpha = 0.5, size = 1.5, color = col_other) +
  geom_smooth(method = "lm", se = TRUE, color = col_other, linewidth = 1.2) +
  annotate("text",
           x = Inf, y = -Inf,
           label = paste0("R² = ", round(MA_r2_ses, 3)),
           hjust = 1.1, vjust = -0.8, size = 4) +
  labs(
    title = paste0(dataset_label, ": SES and Age of MDD Onset (Unadjusted)"),
    x = "Socioeconomic Status (0–1 Scaled)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis

print(MA_fig2)

# 3. Figure 3: Sex Differences
MA_fig3 <- ggplot(master_final, aes(x = sex, y = ageonset)) +
  geom_boxplot(fill = col_other, alpha = 0.6, linewidth = 1) +
  labs(
    title = paste0(dataset_label, ": Sex Differences in Age of MDD Onset"),
    x = "Sex",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis

print(MA_fig3)

# 4.  Figure 4: Main Effects Model Visualization
library(ggeffects)

MA_prs_effect <- ggpredict(MA_model_additive, terms = "MA_PRS_z")
MA_prs_df <- as.data.frame(MA_prs_effect)

MA_fig4 <- ggplot(MA_prs_df, aes(x = x, y = predicted)) +
  geom_line(color = col_MA, linewidth = 1.2) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high),
              fill = col_MA, alpha = 0.2) +
  labs(
    title = paste0(dataset_label, ": Adjusted Effect of MA PRS on Age of MDD Onset"),
    x = "MA Polygenic Risk Score (Z)",
    y = "Predicted Age of Onset"
  ) +
  theme_thesis

print(MA_fig4)

# 5. Figure 5: Model Comparison
MA_model_r2 <- data.frame(
  MA_Model = c("Covariates", "PRS", "Sex", "SES", "Additive"),
  MA_R2 = c(0.0373, 0.03774, 0.04109, 0.04881, 0.0534)
)

MA_fig5 <- ggplot(MA_model_r2, aes(x = MA_Model, y = MA_R2)) +
  geom_col(fill = "grey50") +
  labs(
    title = paste0(dataset_label, ": MA Model R² Comparison"),
    x = "MA Model",
    y = "MA R²"
  ) +
  theme_thesis

print(MA_fig5)
