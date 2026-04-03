##### MA Analyses #####

# 1. Load packages and paths if necessary ####

# 2. Load files if necessary ####
save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"

# Set colors
col_EA <- "steelblue"   # blue = European ancestry
col_MA <- "#B22222"   # red = Multi-ancestry
col_other <- "grey60" # grey = anything else

# 3. Summarize master final ####
master_final <- read.csv(file.path(save_path, "master_final.csv"))
str(master_final)
summary(master_final)

# 4. Descriptive statistics for age of onset ####
mean_age <- mean(master_final$ageonset, na.rm = TRUE)
sd_age   <- sd(master_final$ageonset, na.rm = TRUE)

cat("Age of onset:", round(mean_age,1), "±", round(sd_age,1), "years\n")

## 4.1 Histogram of age of onset 
png(file.path(save_path, "Fig1_age_onset_distribution.png"),
    width = 6, height = 5, units = "in", res = 300)

hist(master_final$ageonset,
     breaks = 20,
     xlab = "Age of Onset (Years)",
     main = "Distribution of Age of Onset",
     col = col_other,
     border = "white")

dev.off()


#========================== EA PRS Modeling ====================================

# 5. Data Cleaning ####
# Recode gender (0 = Male, 1 = Female)
master_final$gender <- factor(master_final$gender,
                              levels = c(0,1),
                              labels = c("Male","Female"))

# Recode race as factor
master_final$race <- as.factor(master_final$race)

# Check structure again
str(master_final)

# 6. Primary Linear Regression Model 1: PRS only + PCs ####
model1_MA <- lm(ageonset ~ MA_PRS_z +
                  EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                data = master_final)

summary(model1_MA)

# 7. Model 2: PRS + gender + SES + PCs ####
model2_MA <- lm(ageonset ~ MA_PRS_z +
                  gender +
                  ses_combined +
                  EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                data = master_final)

summary(model2_MA)

# 8. Model 3: PRS x Sex interaction ####
model3_MA <- lm(ageonset ~ MA_PRS_z * gender +
                  ses_combined +
                  EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                data = master_final)

summary(model3_MA)

# 9. Model 4: PRS x SES interaction ####
model4_MA <- lm(ageonset ~ MA_PRS_z * ses_combined +
                  gender +
                  EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                data = master_final)

summary(model4_MA)

# 10. Model 5: Full model with both interaction terms ####
model_full_MA <- lm(ageonset ~ MA_PRS_z * gender +
                      MA_PRS_z * ses_combined +
                      gender +
                      ses_combined +
                      EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                    data = master_final)

summary(model_full_MA)

# 11. Test gene-environment correlation ####
cor.test(master_final$MA_PRS_z,
         master_final$ses_combined)



# ===================== Creating regression table of results ===================

# Load packages
install.packages("modelsummary")
library(modelsummary)

# Create table
modelsummary(
  list(
    "MA Additive Model" = model2_MA,
    "MA Interaction Model" = model_full_MA
  ),
  estimate = "{estimate}",
  statistic = c("{std.error}", "{p.value}"),
  stars = FALSE,
  output = "markdown"
)


# ======================== Creating Figures ====================================

# 1. Figure 1: PRS & Age of Onset ####
model1_simple_MA <- lm(ageonset ~ MA_PRS_z, data = master_final)
summary(model1_simple_MA)$r.squared

# Extract R2
r2_value <- summary(model1_simple_MA)$r.squared
r2_label <- paste0("Unadjusted R² = ", round(r2_value, 3))

# Plot
ggplot(master_final, aes(x = MA_PRS_z, y = ageonset)) +
  geom_point(alpha = 0.5, size = 1.5, color = "forestgreen") +
  geom_smooth(method = "lm", se = TRUE,
              color = "grey70", linewidth = 1.2) +
  annotate("text",
           x = Inf, y = -Inf,
           label = r2_label,
           hjust = 1.1, vjust = -0.8,
           size = 5) +
  labs(
    title = "MA PRS and Age of MDD Onset",
    x = "MA Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold")
  )

# 2. Figure 2: SES and Age of Onset ####
# Fit SES model (additive model is fine)
model_ses <- lm(ageonset ~ EA_PRS_z + gender + ses_combined +
                  EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                data = master_final)

r2_ses <- summary(model_ses)$r.squared
r2_label_ses <- paste0("R² = ", round(r2_ses, 3))

ggplot(master_final, aes(x = ses_combined, y = ageonset)) +
  geom_point(alpha = 0.5, size = 1.5, color = "grey60") +
  geom_smooth(method = "lm", se = TRUE,
              color = "grey40", linewidth = 1.2) +
  annotate("text",
           x = Inf, y = -Inf,
           label = r2_label_ses,
           hjust = 1.1, vjust = -0.8,
           size = 5) +
  labs(
    title = "Socioeconomic Status and Age of MDD Onset",
    x = "Socioeconomic Status",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold")
  )

# 3. Figure 3: Sex Differences in Age of Onset ####
ggplot(master_final, aes(x = gender, y = ageonset)) +
  geom_boxplot(alpha = 0.7, width = 0.6, fill = "grey70") +
  labs(
    title = "Sex Differences in Age of MDD Onset",
    x = "Sex",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.position = "none"
  )

# 4. Figure 4: EA PRS x Sex ####
ggplot(master_final, aes(x = MA_PRS_z, y = ageonset, color = gender)) +
  geom_point(alpha = 0.4, color = col_MA) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1.2,
              aes(color = gender)) +
  scale_color_manual(values = c("Male" = "grey70",
                                "Female" = "grey30")) +
  labs(
    title = "MA: PRS and Age of Onset by Sex",
    x = "MA Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_classic(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

# Figure 5: EA PRS x SES ####
# Create SES groups by sides of median
master_final$ses_group <- ifelse(
  master_final$ses_combined >= median(master_final$ses_combined, na.rm = TRUE),
  "Higher SES",
  "Lower SES"
)

ggplot(master_final, aes(x = MA_PRS_z, y = ageonset, color = ses_group)) +
  geom_point(alpha = 0.4, color = col_MA) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1.2) +
  scale_color_manual(values = c("Lower SES" = "grey30",
                                "Higher SES" = "grey70")) +
  labs(
    title = "MA: PRS and Age of Onset by Socioeconomic Status",
    x = "MA Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_classic(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))