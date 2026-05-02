# 0. Load packages & dataset if needed ####
library(ggplot2)
library(dplyr)
library(ggeffects)
library(broom)

# 1. Set colors + theme ####
col_EA <- "steelblue"
col_MA <- "#B22222"
col_other <- "#1A8F5A"

theme_thesis <- theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.line = element_line(linewidth = 0.8),
    legend.position = "top"
  )

# Dataset label
dataset_label <- "All of Us"

# Global axis limits
x_prs_lim <- c(-3, 3)   # standard for z-scores
x_ses_lim <- c(0, 1)    # your SES scale

y_coef_lim <- c(-10, 12)

# 2. Figure 6: SES effect ####
y_age_lim <- c(0, 89)

model_ses_simple <- lm(ageonset ~ ses_combined, data = master_final)
r2_ses <- summary(model_ses_simple)$r.squared

fig6 <- ggplot(master_final, aes(x = ses_combined, y = ageonset)) +
  geom_point(alpha = 0.4, size = 1.5, color = col_other) +
  geom_smooth(method = "lm", se = TRUE, color = "black", linewidth = 1.2) +
  coord_cartesian(xlim = x_ses_lim, ylim = y_age_lim) +
  annotate("text",
           x = Inf, y = -Inf,
           label = paste0("R² = ", round(r2_ses, 3)),
           hjust = 1.1, vjust = -0.8, size = 4) +
  labs(
    title = paste0(dataset_label, ": SES and Age of MDD Onset"),
    x = "Socioeconomic Status (0–1 Scaled)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis

print(fig6)

# 3. Figure 8: Adjusted PRS Effect (EA vs MA)
y_age_lim <- c(20, 55)
EA_effect <- ggpredict(model_additive, terms = "EA_PRS_z") %>%
  as.data.frame() %>%
  mutate(Type = "EA PRS")

MA_effect <- ggpredict(MA_model_additive, terms = "MA_PRS_z") %>%
  as.data.frame() %>%
  mutate(Type = "MA PRS")

prs_df <- bind_rows(EA_effect, MA_effect)

fig8 <- ggplot(prs_df, aes(x = x, y = predicted, color = Type, fill = Type)) +
  geom_line(linewidth = 1.2) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.2, color = NA) +
  scale_color_manual(values = c("EA PRS" = col_EA, "MA PRS" = col_MA)) +
  scale_fill_manual(values = c("EA PRS" = col_EA, "MA PRS" = col_MA)) +
  coord_cartesian(xlim = x_prs_lim, ylim = y_age_lim) +
  labs(
    title = paste0(dataset_label, ": Adjusted Effect of PRS on Age of Onset"),
    x = "Polygenic Risk Score (Z)",
    y = "Predicted Age of Onset",
    color = "PRS Type",
    fill = "PRS Type"
  ) +
  theme_thesis

print(fig8)

# 4. Figure 10: Model Comparison ####
model_r2 <- data.frame(
  Model = rep(c("Covariates", "PRS", "Sex", "SES", "Additive"), 2),
  R2 = c(0.03538, 0.03569, 0.03905, 0.04678, 0.05115,
         0.03538, 0.03619, 0.03905, 0.04678, 0.05172),
  Type = rep(c("EA", "MA"), each = 5)
)

model_r2$Model <- factor(
  model_r2$Model,
  levels = c("Covariates", "PRS", "Sex", "SES", "Additive")
)

fig10 <- ggplot(model_r2, aes(x = Model, y = R2, fill = Type)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c("EA" = col_EA, "MA" = col_MA)) +
  labs(
    title = paste0(dataset_label, ": Model R² Comparison"),
    x = "Model",
    y = expression(R^2),
    fill = "PRS Type"
  ) +
  theme_thesis

print(fig10)

# 5. Figure 9: Coefficient Plot ####
EA_coefs <- tidy(model_additive, conf.int = TRUE) %>%
  mutate(Type = "EA") %>%
  filter(term %in% c("EA_PRS_z", "sexFemale", "ses_combined"))

MA_coefs <- tidy(MA_model_additive, conf.int = TRUE) %>%
  mutate(Type = "MA") %>%
  filter(term %in% c("MA_PRS_z", "sexFemale", "ses_combined"))

coef_df <- bind_rows(EA_coefs, MA_coefs)

# Clean labels for figure
coef_df$term <- recode(coef_df$term,
                       "EA_PRS_z" = "PRS",
                       "MA_PRS_z" = "PRS",
                       "sexFemale" = "Sex",
                       "ses_combined" = "SES")

# Ensure correct ordering
coef_df$term <- factor(coef_df$term,
                       levels = c("PRS", "Sex", "SES"))

fig9 <- ggplot(coef_df, aes(x = term, y = estimate, color = Type)) +
  
  geom_hline(yintercept = 0, linetype = "dashed") +
  
  geom_point(position = position_dodge(width = 0.4), size = 3) +
  
  geom_errorbar(
    aes(ymin = conf.low, ymax = conf.high),
    position = position_dodge(width = 0.4),
    width = 0.2
  ) +
  
  scale_color_manual(values = c(
    "EA" = col_EA,
    "MA" = col_MA
  )) +
  
  coord_cartesian(ylim = y_coef_lim) +
  
  labs(
    title = paste0(dataset_label, ": Effect Sizes from Additive Model"),
    x = "Predictor",
    y = "Beta Coefficient",
    color = "Ancestry"
  ) +
  
  theme_thesis

print(fig9)

# 6. Figure 7: Sex Differences
y_age_lim <- c(0, 89)

fig7 <- ggplot(master_final, aes(x = sex, y = ageonset, fill = sex)) +
  geom_boxplot(alpha = 0.6, linewidth = 1, outlier.shape = NA) +
  scale_fill_manual(values = c("Male" = col_other, "Female" = col_other)) +
  coord_cartesian(ylim = y_age_lim) +
  labs(
    title = paste0(dataset_label, ": Sex Differences in Age of MDD Onset"),
    x = "Sex",
    y = "Age of MDD Onset (Years)",
    fill = "Sex"
  ) +
  theme_thesis +
  theme(legend.position = "none")

print(fig7)
