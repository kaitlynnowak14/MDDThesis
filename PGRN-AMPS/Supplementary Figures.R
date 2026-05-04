# 2. Age Distribution ####
x_age_lim <- c(15, 89)

fig_age_dist <- ggplot(master_final, aes(x = age)) +
  geom_histogram(bins = 40, fill = col_other, color = "black", alpha = 0.7) +
  coord_cartesian(xlim = x_age_lim) +
  labs(
    title = paste0(dataset_label, ": Age Distribution"),
    x = "Age (Years)",
    y = "Count"
  ) +
  theme_thesis

print(fig_age_dist)
