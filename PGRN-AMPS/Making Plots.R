##### Making Plots #####

# 0. Load Libararies and paths ####
library(ggplot2)
library(tidyverse)

save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"

# ----------------------
# EA Plots
# ----------------------
# 1. Basic PRS Distribution ####
## 1.1 Histogram
EA_PRS_hist_plot <- ggplot(master_EA_clean, aes(x = EA_PRS_z)) +
  geom_histogram(bins = 50, fill = "steelblue", color = "black") +
  theme_minimal() +
  labs(title = "Distribution of EA Polygenic Risk Score",
       x = "EA PRS (z-score)", y = "Count")

ggsave(filename = file.path(save_path, "EA_PRS_histogram.png"),
       plot = EA_PRS_hist_plot, width = 6, height = 4, dpi = 300)

## 1.2 Density Plot
EA_PRS_density_plot <- ggplot(master_EA_clean, aes(x = EA_PRS_z)) +
  geom_density(fill = "steelblue", alpha = 0.5) +
  theme_minimal() +
  labs(title = "Density of EA Polygenic Risk Score",
       x = "EA PRS (z-score)", y = "Density")

ggsave(filename = file.path(save_path, "EA_PRS_density.png"),
       plot = EA_PRS_density_plot, width = 6, height = 4, dpi = 300)

# 2. PRS vs Age of Onset ####
EA_ageonset_plot <- ggplot(master_EA_clean,
                           aes(x = EA_PRS_z, y = ageonset)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_smooth(method = "lm", se = TRUE, color = "black") +
  theme_minimal() +
  labs(
    title = "EA Polygenic Risk Score and Age of Onset",
    x = "EA PRS (z-score)",
    y = "Age of Onset (years)"
  )

ggsave(
  file.path(save_path, "EA_PRS_vs_AgeOnset.png"),
  EA_ageonset_plot,
  width = 6, height = 4, dpi = 300
)

# 3. PRS by Sex
EA_sex_plot <- ggplot(master_EA_clean,
                      aes(x = gender, y = EA_PRS_z, fill = gender)) +
  geom_violin(trim = FALSE, alpha = 0.6) +
  geom_boxplot(width = 0.15, outlier.shape = NA, alpha = 0.8) +
  scale_fill_manual(
    values = c("F" = "steelblue", "M" = "lightblue")
  ) +
  theme_minimal() +
  labs(
    title = "EA Polygenic Risk Score by Sex",
    x = "Sex",
    y = "EA PRS (z-score)"
  )

ggsave(
  file.path(save_path, "EA_PRS_by_Sex.png"),
  EA_sex_plot,
  width = 5, height = 4, dpi = 300
)

# ----------------------
# MA Plots
# ----------------------
# 1. Basic PRS Distribution ####
## 1.1 Histogram
MA_PRS_hist_plot <- ggplot(master_MA_clean, aes(x = MA_PRS_z)) +
  geom_histogram(bins = 50, fill = "#B22222", color = "black") +
  theme_minimal() +
  labs(title = "Distribution of MA Polygenic Risk Score",
       x = "MA PRS (z-score)", y = "Count")

ggsave(filename = file.path(save_path, "MA_PRS_histogram.png"),
       plot = MA_PRS_hist_plot, width = 6, height = 4, dpi = 300)

## 1.2 Density Plot
MA_PRS_density_plot <- ggplot(master_MA_clean, aes(x = MA_PRS_z)) +
  geom_density(fill = "#B22222", alpha = 0.5) +
  theme_minimal() +
  labs(title = "Density of MA Polygenic Risk Score",
       x = "MA PRS (z-score)", y = "Density")

ggsave(filename = file.path(save_path, "MA_PRS_density.png"),
       plot = MA_PRS_density_plot, width = 6, height = 4, dpi = 300)

# 2. PRS vs Age of Onset ####
MA_ageonset_plot <- ggplot(master_MA_clean,
                           aes(x = MA_PRS_z, y = ageonset)) +
  geom_point(alpha = 0.5, color = "#B22222") +
  geom_smooth(method = "lm", se = TRUE, color = "black") +
  theme_minimal() +
  labs(
    title = "MA Polygenic Risk Score and Age of Onset",
    x = "MA PRS (z-score)",
    y = "Age of Onset (years)"
  )

ggsave(
  file.path(save_path, "MA_PRS_vs_AgeOnset.png"),
  MA_ageonset_plot,
  width = 6, height = 4, dpi = 300
)

# 3. PRS by Sex
MA_sex_plot <- ggplot(master_MA_clean,
                      aes(x = gender, y = MA_PRS_z, fill = gender)) +
  geom_violin(trim = FALSE, alpha = 0.6) +
  geom_boxplot(width = 0.15, outlier.shape = NA, alpha = 0.8) +
  scale_fill_manual(
    values = c("F" = "#B22222", "M" = "#F4A6A6")
  ) +
  theme_minimal() +
  labs(
    title = "MA Polygenic Risk Score by Sex",
    x = "Sex",
    y = "EM PRS (z-score)"
  )

ggsave(
  file.path(save_path, "MA_PRS_by_Sex.png"),
  MA_sex_plot,
  width = 5, height = 4, dpi = 300
)


# ----------------------
# Overlay/Comparison Plots
# ----------------------
# 1. Overlaid Density Plot ####
## Combine PRS for plotting
PRS_compare <- bind_rows(
  master_EA_clean %>%
    select(FID, IID, PRS = EA_PRS_z) %>%
    mutate(Group = "EA"),
  
  master_MA_clean %>%
    select(FID, IID, PRS = MA_PRS_z) %>%
    mutate(Group = "MA")
)

EA_MA_density_plot <- ggplot(PRS_compare, aes(x = PRS, fill = Group)) +
  geom_density(alpha = 0.4) +
  scale_fill_manual(
    values = c("EA" = "steelblue", "MA" = "#B22222")
  ) +
  theme_minimal() +
  labs(
    title = "Density of Standardized Polygenic Risk Scores",
    x = "PRS (z-score)",
    y = "Density",
    fill = "PRS Type"
  )

ggsave(
  file.path(save_path, "EA_vs_MA_PRS_density.png"),
  EA_MA_density_plot,
  width = 6, height = 4, dpi = 300
)


##### look at AOO distribution by sex #####
# Welch two-sample t-test: Age of onset by gender
t_sex_aoo <- t.test(ageonset ~ gender, data = master_final)
t_sex_aoo

# Recode gender as factor for plotting
master_EA_final$gender_f <- factor(
  master_EA_final$gender,
  levels = c(0, 1),
  labels = c("Male", "Female")
)

# Compute y-axis limits with extra headroom
y_max <- max(master_EA_final$ageonset, na.rm = TRUE)
y_lim <- c(0, y_max + 8)

png(file.path(save_path, "Fig5_AgeOnset_by_Gender.png"),
    width = 6, height = 5, units = "in", res = 300)

boxplot(ageonset ~ gender_f,
        data = master_EA_final,
        xlab = "Gender",
        ylab = "Age of Onset (Years)",
        main = "Age of Onset by Gender",
        col = c("grey70", col_EA),
        border = "grey30",
        ylim = y_lim)

# --- Significance annotation (now safely above data) ---
bar_y  <- y_max + 3
text_y <- y_max + 5

segments(1, bar_y, 2, bar_y, lwd = 1.5)
segments(1, bar_y - 0.5, 1, bar_y)
segments(2, bar_y - 0.5, 2, bar_y)

text(1.5, text_y, "p = 0.038 *", cex = 0.9)

dev.off()
