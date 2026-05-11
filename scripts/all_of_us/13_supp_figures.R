# ============================================================
# Title: Distribution Plots for PRS, Age, and Genetic Structure
# Dataset: All of Us Master Phenotype Dataset (master_final)
#
# Description:
#   - Visualizes distribution of EA and MA polygenic risk scores
#   - Plots age and age of onset distributions
#   - Displays genetic ancestry structure using PCA (PC1 vs PC2)
#
# Outputs:
#   - PRS density plot
#   - Age histogram
#   - Age of onset histogram
#   - PCA scatter plot
#
# Notes:
#   - PRS values are standardized (z-scored)
#   - PCA reflects ancestry structure (PC1–PC2 space)
# ============================================================

# =====================================================
# 0. PREVIOUS PACKAGES AND THEMES ALREADY LOADED
# =====================================================

# =====================================================
# 1. PRS DISTRIBUTION (DENSITY PLOTS)
# =====================================================

PRS_density <- ggplot() +
  geom_density(
    data = master_final,
    aes(x = EA_PRS_z, fill = "EA PRS"),
    alpha = 0.4
  ) +
  geom_density(
    data = master_final,
    aes(x = MA_PRS_z, fill = "MA PRS"),
    alpha = 0.4
  ) +
  scale_fill_manual(
    values = c("EA PRS" = "black", "MA PRS" = col_AoU),
    name = " "
  ) +
  coord_cartesian(xlim = x_prs_lim) +
  labs(
    title = paste0(dataset_label, ": Distribution of Polygenic Risk Scores"),
    x = "PRS (Z-score)",
    y = "Density"
  ) +
  theme_thesis +
  theme(legend.position = "top")

print(PRS_density)

# =====================================================
# 2. AGE DISTRIBUTION
# =====================================================

x_age_lim <- c(15, 100)

fig_age_dist <- ggplot(master_final, aes(x = age_at_survey)) +
  geom_histogram(bins = 40, fill = col_AoU, color = "black", alpha = 0.7) +
  coord_cartesian(xlim = x_age_lim) +
  labs(
    title = paste0(dataset_label, ": Age Distribution"),
    x = "Age (Years)",
    y = "Count"
  ) +
  theme_thesis

print(fig_age_dist)

# =====================================================
# 3. AGE OF ONSET DISTRIBUTION
# =====================================================

x_age_lim <- c(0, 100)

fig_onset_dist <- ggplot(master_final, aes(x = ageonset)) +
  geom_histogram(bins = 40, fill = col_AoU, color = "black", alpha = 0.7) +
  coord_cartesian(xlim = x_age_lim) +
  labs(
    title = paste0(dataset_label, ": Age of MDD Onset Distribution"),
    x = "Age of MDD Onset (Years)",
    y = "Count"
  ) +
  theme_thesis

print(fig_onset_dist)

# =====================================================
# 4. GENETIC ANCESTRY PCA (PC1 vs PC2)
# =====================================================

fig_pca <- ggplot(master_final, aes(x = pc_1, y = pc_2)) +
  geom_point(alpha = 0.4, size = 1.5, color = col_AoU) +
  labs(
    title = paste0(dataset_label, ": Genetic Ancestry PCA (PC1 vs PC2)"),
    x = "PC1",
    y = "PC2"
  ) +
  theme_thesis

print(fig_pca)
