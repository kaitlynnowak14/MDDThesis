# ============================================================
# Title: Visualization of PRS, SES, and Sex Associations with Age of Onset
# Dataset: All of Us Final Merged Dataset (EA/MA PRS + Phenotypes)
#
# Description:
#   - Generate univariate association plots
#   - Visualize PRS, SES, and sex effects on age of onset
#   - Compare nested model R² progression
#
# Output:
#   - SES regression plot
#   - Sex distribution plots
#   - PRS association plot
#   - Nested model R² figure
#
# Notes:
#   - All models are unadjusted unless explicitly labeled
# ============================================================

# =====================================================
# 0. LOAD PACKAGES
# =====================================================

library(ggplot2)
library(dplyr)
library(ggeffects)
library(broom)
library(ggpattern)

# =====================================================
# 1. SET COLORS AND THEME
# =====================================================

col_AoU <- "indianred3"

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
x_prs_lim <- c(-3, 3)
x_ses_lim <- c(0, 1)
y_age_lim <- c(0,100)

# =====================================================
# 2. UNIVARIATE FIGURES (UNADJUSTED MODELS)
# =====================================================

# ---- SES Association ----
y_age_lim <- c(0, 89)

model_ses <- lm(ageonset ~ ses_combined, data = master_final)
r2_ses <- summary(model_ses)$r.squared

fig_ses <- ggplot(master_final, aes(x = ses_combined, y = ageonset)) +
  geom_point(alpha = 0.4, size = 1.4, color = col_AoU) +
  geom_smooth(method = "lm", se = TRUE, color = col_AoU, linewidth = 1.1) +
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

# ---- Sex Association ----
fig_sex <- ggplot(master_final, aes(x = sex, y = ageonset, fill = sex)) +
  geom_boxplot(alpha = 0.6, linewidth = 0.9, outlier.shape = NA) +
  scale_fill_manual(values = c("Male" = col_AoU, "Female" = col_AoU)) +
  coord_cartesian(ylim = y_age_lim) +
  labs(
    title = paste0(dataset_label, ": Sex Differences in Age of Onset (Unadjusted)"),
    x = "Sex",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis +
  theme(legend.position = "none")

print(fig_sex)

# ---- Sex Association with Patterned Boxplot for Females ----
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
    "Male" = col_AoU,
    "Female" = col_AoU
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

# ---- PRS Association ----
y_age_lim <- c(15,60)

r2_ea <- summary(model_ea_prs)$r.squared
r2_ma <- summary(model_ma_prs)$r.squared

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
  
  # MA PRS (red dashed)
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
    "MA" = col_AoU
  )) +
  
  scale_fill_manual(values = c(
    "EA" = "black",
    "MA" = col_AoU
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

# =====================================================
# 3. NESTED MODEL PERFORMANCE (R² PROGRESSION)
# =====================================================

model_r2 <- data.frame(
  Model = rep(c("PCs", "PCs + SES", "PCs + SES + Sex", "Full Model"), 2),
  R2 = c(
    0.03538, 0.04678, 0.05071, 0.05115,   # EA
    0.03538, 0.04678, 0.05071, 0.05172    # MA
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
    "MA" = col_AoU
  )) +
  
  # linetype mapping
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
