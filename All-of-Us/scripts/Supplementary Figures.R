# 1. PRS Density ####
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
    values = c(
      "EA PRS" = col_EA,
      "MA PRS" = col_MA
    ),
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

# 2. Age Distribution ####
fig_age_dist <- ggplot(master_final, aes(x = age_at_survey)) +
  geom_histogram(bins = 40, fill = col_other, color = "black", alpha = 0.7) +
  labs(
    title = paste0(dataset_label, ": Age Distribution"),
    x = "Age (Years)",
    y = "Count"
  ) +
  theme_thesis

print(fig_age_dist)

# 3. Age of Onset Distribution ####
fig_onset_dist <- ggplot(master_final, aes(x = ageonset)) +
  geom_histogram(bins = 40, fill = col_other, color = "black", alpha = 0.7) +
  labs(
    title = paste0(dataset_label, ": Age of MDD Onset Distribution"),
    x = "Age of MDD Onset (Years)",
    y = "Count"
  ) +
  theme_thesis

print(fig_onset_dist)

# 4. PCA Plot ####
fig_pca <- ggplot(master_final, aes(x = pc_1, y = pc_2)) +
  geom_point(alpha = 0.4, size = 1.5, color = col_other) +
  labs(
    title = paste0(dataset_label, ": Genetic Ancestry PCA (PC1 vs PC2)"),
    x = "PC1",
    y = "PC2"
  ) +
  theme_thesis

print(fig_pca)
