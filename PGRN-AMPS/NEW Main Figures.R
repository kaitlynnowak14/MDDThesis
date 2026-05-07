# 0. Load packages & dataset if needed ####
library(ggplot2)
library(dplyr)
library(ggeffects)
library(broom)
library(ggpattern)

# 1. Set colors + theme ####
col_PGRN <- "steelblue"

theme_thesis <- theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.line = element_line(linewidth = 0.8),
    legend.position = "top"
  )

# Dataset label
dataset_label <- "PGRN-AMPS"

# Global axis limits
x_prs_lim <- c(-3, 3)
x_ses_lim <- c(0, 1)
y_age_lim <- c(0,100)

# ========================== Univariate Unadjusted Figures =====================

# 1. SES ####
y_age_lim <- c(0, 89)

model_ses <- lm(ageonset ~ ses_combined, data = master_final)
r2_ses <- summary(model_ses)$r.squared

fig_ses <- ggplot(master_final, aes(x = ses_combined, y = ageonset)) +
  geom_point(alpha = 0.4, size = 1.4, color = col_PGRN) +
  geom_smooth(method = "lm", se = TRUE, color = col_PGRN, linewidth = 1.1) +
  coord_cartesian(xlim = x_ses_lim, ylim = y_age_lim) +
  annotate("text",
           x = Inf, y = -Inf,
           label = paste0("R² = ", round(r2_ses, 3)),
           hjust = 1.1, vjust = -0.8, size = 4) +
  labs(
    title = paste0(dataset_label, ": SES and Age of Onset (Unadjusted)"),
    x = "Socioeconomic Status (0–1)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis

print(fig_ses)

# 2. Sex ####
fig_sex <- ggplot(master_final, aes(x = sex, y = ageonset, fill = sex)) +
  geom_boxplot(alpha = 0.6, linewidth = 0.9, outlier.shape = NA) +
  scale_fill_manual(values = c("Male" = col_PGRN, "Female" = col_PGRN)) +
  coord_cartesian(ylim = y_age_lim) +
  labs(
    title = paste0(dataset_label, ": Sex Differences in Age of Onset (Unadjusted)"),
    x = "Sex",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis +
  theme(legend.position = "none")

print(fig_sex)

# With female pattern
fig_sex_pattern <- ggplot(master_final, aes(x = sex, y = ageonset)) +
  
  geom_boxplot_pattern(
    aes(
      fill = sex,
      pattern = sex
    ),
    alpha = 0.7,
    linewidth = 0.9,
    outlier.shape = NA,
    
    pattern_density = 0.4,
    pattern_spacing = 0.04,
    pattern_angle = 45,
    pattern_colour = "black"
  ) +
  
  scale_fill_manual(values = c(
    "Male" = col_PGRN,
    "Female" = col_PGRN
  )) +
  
  scale_pattern_manual(values = c(
    "Male" = "none",
    "Female" = "stripe"
  )) +
  
  coord_cartesian(ylim = y_age_lim) +
  
  labs(
    title = paste0(dataset_label, ": Sex Differences in Age of Onset (Unadjusted)"),
    x = "Sex",
    y = "Age of MDD Onset (Years)"
  ) +
  
  theme_thesis +
  theme(
    legend.position = "none"
  )

print(fig_sex_pattern)

# 3. PRS ####
y_age_lim <- c(15,60)

fig_prs <- ggplot(master_final, aes(y = ageonset)) +
  
  # EA PRS (black solid)
  geom_smooth(
    aes(
      x = EA_PRS_z,
      color = "EA",
      fill = "EA",
      linetype = "EA"
    ),
    method = "lm",
    se = TRUE,
    linewidth = 1.1,
    alpha = 0.15
  ) +
  
  # MA PRS (blue dashed)
  geom_smooth(
    aes(
      x = MA_PRS_z,
      color = "MA",
      fill = "MA",
      linetype = "MA"
    ),
    method = "lm",
    se = TRUE,
    linewidth = 1.1,
    alpha = 0.15
  ) +
  
  scale_color_manual(values = c(
    "EA" = "black",
    "MA" = col_PGRN
  )) +
  
  scale_fill_manual(values = c(
    "EA" = "black",
    "MA" = col_PGRN
  )) +
  
  scale_linetype_manual(values = c(
    "EA" = "solid",
    "MA" = "dashed"
  )) +
  
  coord_cartesian(xlim = x_prs_lim, ylim = y_age_lim) +
  
  annotate(
    "text",
    x = x_prs_lim[1] + 0.3,
    y = 16,
    label = paste0(
      "EA R² = ", round(r2_ea, 3),
      "\nMA R² = ", round(r2_ma, 3)
    ),
    hjust = 0,
    vjust = 0,
    size = 4
  ) +
  
  labs(
    title = paste0(dataset_label, ": PRS and Age of Onset (Unadjusted)"),
    x = "Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)",
    color = "PRS Type",
    fill = "PRS Type",
    linetype = "PRS Type"
  ) +
  
  theme_thesis

print(fig_prs)

# ============================== Nested Figures ================================

# 1. R2 Progression Plot ####
model_r2 <- data.frame(
  Model = rep(c("PCs", "PCs + SES", "PCs + SES + Sex", "Full Model"), 2),
  R2 = c(
    -0.0006328, 0.03225, 0.03947, 0.04913,   # EA
    -0.0006328, 0.03225, 0.03947, 0.05365    # MA
  ),
  Type = rep(c("EA", "MA"), each = 4)
)

model_r2$Model <- factor(
  model_r2$Model,
  levels = c("PCs", "PCs + SES", "PCs + SES + Sex", "Full Model")
)

fig_nested_r2 <- ggplot(model_r2, aes(x = Model, y = R2, group = Type)) +
  
  # lines
  geom_line(aes(color = Type, linetype = Type), linewidth = 1.2) +
  
  # points
  geom_point(aes(color = Type), size = 3) +
  
  # color mapping (your thesis palette)
  scale_color_manual(values = c(
    "EA" = "black",
    "MA" = col_PGRN
  )) +
  
  # linetype mapping (key improvement)
  scale_linetype_manual(values = c(
    "EA" = "solid",
    "MA" = "dashed"
  )) +
  
  coord_cartesian(ylim = c(0, 0.06)) +
  
  labs(
    title = paste0(dataset_label, ": Nested Model Fit (R² Increase)"),
    x = "Model Specification",
    y = expression(R^2),
    color = "Cohort",
    linetype = "Cohort"
  ) +
  
  theme_thesis

print(fig_nested_r2)
