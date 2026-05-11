# ============================================================================
# Title: PGRN-AMPS Distribution & PCA Visualizations
# Dataset: PGRN-AMPS Cohort
#
# Description:
#   - Visualize PRS score distributions for EA and MA models
#   - Plot participant age and age of onset distributions
#   - Generate PCA ancestry visualization using principal components
#
# Output:
#   PRS density plots
#   Age distribution histograms
#   Age of onset histograms
#   PCA ancestry scatterplot
#
# Notes:
#   - EA PRS displayed in black
#   - MA PRS displayed in thesis blue palette
#   - PCA visualization uses EVEC.1 and EVEC.2
# ============================================================================

# =====================================================
# 1. PRS DENSITY DISTRIBUTIONS
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
    values = c("EA PRS" = "black", "MA PRS" = col_PGRN),
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

fig_age_dist <- ggplot(master_final, aes(x = age)) +
  geom_histogram(bins = 40, fill = col_PGRN, color = "black", alpha = 0.7) +
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
  geom_histogram(bins = 40, fill = col_PGRN, color = "black", alpha = 0.7) +
  coord_cartesian(xlim = x_age_lim) +
  labs(
    title = paste0(dataset_label, ": Age of MDD Onset Distribution"),
    x = "Age of MDD Onset (Years)",
    y = "Count"
  ) +
  theme_thesis

print(fig_onset_dist)

# =====================================================
# 4. GENETIC ANCESTRY PCA VISUALIZATION
# =====================================================

fig_pca <- ggplot(master_final, aes(x = EVEC.1, y = EVEC.2)) +
  geom_point(alpha = 0.4, size = 1.5, color = col_PGRN) +
  labs(
    title = paste0(dataset_label, ": Genetic Ancestry PCA (PC1 vs PC2)"),
    x = "PC1",
    y = "PC2"
  ) +
  theme_thesis

print(fig_pca)
