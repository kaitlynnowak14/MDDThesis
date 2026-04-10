# 0. Load packages & set paths ####
library(data.table)
library(dplyr)
library(ggplot2)

# 1. Load files ####
system("gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/final_merged_dataset.csv .")

master_final <- fread("final_merged_dataset.csv")

# 2. Rename important columns & clean dataset ####

# clean dataset by removing z-scored SES variables
master_final <- master_final |>
  dplyr::select(
    -education_z,
    -employment_z,
    -marital_z,
    -SES_score_z
  )

master_final <- master_final %>%
  rename(
    ageonset = age_of_onset,   # age of onset
    sex = sex_at_birth,          # rename sex column
    ses_combined = SES_score # SES score to match dbGaP "ses_combined"
  )

# Set colors
col_EA <- "steelblue"   # blue = European ancestry
col_MA <- "#B22222"   # red = Multi-ancestry
col_other <- "grey60" # grey = anything else

# 3. Descriptive statistics for age of onset ####
mean_age <- mean(master_final$ageonset, na.rm = TRUE)
sd_age   <- sd(master_final$ageonset, na.rm = TRUE)

cat("Age of onset:", round(mean_age,1), "±", round(sd_age,1), "years\n")

# Histogram
hist(master_final$ageonset,
     breaks = 20,
     xlab = "Age of Onset (Years)",
     main = "Distribution of Age of Onset",
     col = col_other,
     border = "white")

dev.off()

# 4. Primary Linear Regression Model 1: PRS only + PCs ####
model1 <- lm(ageonset ~ EA_PRS_z +
               pc_1 + pc_2 + pc_3 + pc_4,
             data = master_final)

summary(model1)

# 5. Model 2: PRS + sex + SES + PCs ####
# Convert to factor first
master_final$sex <- factor(master_final$sex, levels = c("Male", "Female"))

model2 <- lm(ageonset ~ EA_PRS_z +
               sex +
               ses_combined +
               pc_1 + pc_2 + pc_3 + pc_4,
             data = master_final)

summary(model2)

# 6. Model 3: PRS x Sex interaction ####
model3 <- lm(ageonset ~ EA_PRS_z * sex +
               ses_combined +
               pc_1 + pc_2 + pc_3 + pc_4,
             data = master_final)

summary(model3)

# 7. Model 4: PRS x SES interaction ####
model4 <- lm(ageonset ~ EA_PRS_z * ses_combined +
               sex +
               pc_1 + pc_2 + pc_3 + pc_4,
             data = master_final)

summary(model4)

# 8. Model 5: Full model with both interaction terms ####
model_full <- lm(ageonset ~ EA_PRS_z * sex +
                   EA_PRS_z * ses_combined +
                   sex +
                   ses_combined +
                   pc_1 + pc_2 + pc_3 + pc_4,
                 data = master_final)

summary(model_full)

# 9. Test gene-environment correlation ####
cor.test(master_final$EA_PRS_z,
         master_final$ses_combined)

# 10. Test PRS & Sex
model6 <- lm(ageonset ~ EA_PRS_z +
               sex +
               pc_1 + pc_2 + pc_3 + pc_4,
             data = master_final)

summary(model6)

# 11. Test PRS & SES
model7 <- lm(ageonset ~ EA_PRS_z +
               ses_combined +
               pc_1 + pc_2 + pc_3 + pc_4,
             data = master_final)

summary(model7)

# ======================== Creating Figures ====================================

# 1. Figure 1: PRS & Age of Onset ####
model1_simple <- lm(ageonset ~ EA_PRS_z, data = master_final)
summary(model1_simple)$r.squared

# Extract R2
r2_value <- summary(model1_simple)$r.squared
r2_label <- paste0("Unadjusted R² = ", round(r2_value, 4))

# Plot
ggplot(master_final, aes(x = EA_PRS_z, y = ageonset)) +
  geom_point(alpha = 0.5, size = 1.5, color = "steelblue") +
  geom_smooth(method = "lm", se = TRUE,
              color = "grey60", linewidth = 1.2) +
  annotate("text",
           x = Inf, y = -Inf,
           label = r2_label,
           hjust = 1.1, vjust = -0.8,
           size = 5) +
  labs(
    title = "EA PRS and Age of MDD Onset",
    x = "EA Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold")
  )

# 2. Figure 2: SES and Age of Onset ####
# Fit SES model (additive model is fine)
model_ses <- lm(ageonset ~ EA_PRS_z + sex + ses_combined +
                  pc_1 + pc_2 + pc_3 + pc_4,
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

dev.off()

# 3. Figure 3: Sex Differences in Age of Onset
sex_summary <- master_final %>%
  group_by(sex) %>%
  summarise(
    n = n(),
    mean = mean(ageonset, na.rm = TRUE),
    sd = sd(ageonset, na.rm = TRUE),
    median = median(ageonset, na.rm = TRUE),
    Q1 = quantile(ageonset, 0.25, na.rm = TRUE),
    Q3 = quantile(ageonset, 0.75, na.rm = TRUE),
    IQR = IQR(ageonset, na.rm = TRUE),
    min = min(ageonset, na.rm = TRUE),
    max = max(ageonset, na.rm = TRUE)
  )

sex_summary

ggplot(master_final, aes(x = sex, y = ageonset)) + 
  
  geom_boxplot(
    alpha = 0.7,
    width = 0.6,
    fill = "forestgreen",
    linewidth = 1.4   # thicker lines for poster
  ) + 
  
  labs(
    title = "Sex Differences in Age of MDD Onset",
    x = "Sex",
    y = "Age of MDD Onset (Years)"
  ) + 
  
  theme_classic(base_size = 22) + 
  
  theme(
    plot.title = element_text(
      size = 38,
      hjust = 0.5,
      face = "bold"
    ),
    axis.title = element_text(size = 32, face = "bold"),
    axis.text = element_text(size = 26),
    axis.line = element_line(linewidth = 1.2),
    axis.ticks = element_line(linewidth = 1.2),
    legend.position = "none"
  )

# 4. Figure 4: EA PRS x Sex
ggplot(master_final, aes(x = EA_PRS_z, y = ageonset, color = sex)) +
  geom_point(alpha = 0.4, color = "steelblue") +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1.2,
              aes(color = sex)) +
  scale_color_manual(values = c("Male" = "grey70",
                                "Female" = "grey30")) +
  labs(
    title = "EA: PRS and Age of Onset by Sex",
    x = "EA Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold")
  )

# Figure 5: EA PRS x SES ####
# Create SES groups by sides of median
master_final$ses_group <- ifelse(
  master_final$ses_combined >= median(master_final$ses_combined, na.rm = TRUE),
  "Higher SES",
  "Lower SES"
)

ggplot(master_final, aes(x = EA_PRS_z, y = ageonset, color = ses_group)) +
  geom_point(alpha = 0.4, color = "steelblue") +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1.2) +
  scale_color_manual(values = c("Lower SES" = "grey30",
                                "Higher SES" = "grey70")) +
  labs(
    title = "EA: PRS and Age of Onset by Socioeconomic Status",
    x = "EA Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold")
  )

# Figure 6: Additive Model ####
# Create prediction data
newdata <- expand.grid(
  EA_PRS_z = seq(min(master_final$EA_PRS_z, na.rm = TRUE),
                 max(master_final$EA_PRS_z, na.rm = TRUE),
                 length.out = 100),
  sex = "Male",
  ses_combined = mean(master_final$ses_combined, na.rm = TRUE),
  pc_1 = 0,
  pc_2 = 0,
  pc_3 = 0,
  pc_4 = 0
)

# Generate predictions with standard errors
predictions <- predict(model2, newdata, se.fit = TRUE)

# Add predictions + CI to newdata
newdata$pred <- predictions$fit
newdata$lower <- predictions$fit - 1.96 * predictions$se.fit
newdata$upper <- predictions$fit + 1.96 * predictions$se.fit

# Extract R2 from additive model
r2_value <- summary(model2)$r.squared
r2_label <- paste0("R² = ", round(r2_value, 3))

ggplot() +
  geom_point(data = master_final,
             aes(x = EA_PRS_z, y = ageonset),
             alpha = 0.5, color = "forestgreen", size = 3) +
  
  geom_ribbon(data = newdata,
              aes(x = EA_PRS_z,
                  ymin = lower,
                  ymax = upper),
              fill = "black",
              alpha = 0.15) +
  
  geom_line(data = newdata,
            aes(x = EA_PRS_z, y = pred),
            color = "black",
            linewidth = 1.6) +
  
  annotate("text",
           x = Inf, y = -Inf,
           label = r2_label,
           hjust = 1.1, vjust = -0.6,
           size = 8) +   # scaled for poster
  
  labs(
    title = "Adjusted Association Between EA PRS\nand Age of MDD Onset",
    x = "EA Polygenic Risk Score (Z)",
    y = "Predicted Age of MDD Onset (Years)"
  ) +
  
  theme_classic(base_size = 22) +
  theme(
    plot.title = element_text(size = 38,
                              hjust = 0.5,
                              face = "bold"),
    axis.title = element_text(size = 32, face = "bold"),
    axis.text = element_text(size = 26),
    axis.line = element_line(linewidth = 1.2),
    axis.ticks = element_line(linewidth = 1.2)
  )

# SES and AOO for poster
ggplot(master_final, aes(x = ses_combined, y = ageonset)) +
  geom_point(alpha = 0.5, color = "forestgreen", size = 3) +
  
  geom_smooth(method = "lm",
              se = TRUE,
              color = "black",
              linewidth = 1.6) +
  
  labs(
    title = "Association Between Socioeconomic\nStatus and Age of MDD Onset",
    x = "Socioeconomic Status (Scaled 0–1)",
    y = "Age of MDD Onset (Years)"
  ) +
  
  theme_classic(base_size = 22) +
  theme(
    plot.title = element_text(
      size = 38,
      hjust = 0.5,
      face = "bold"
    ),
    axis.title = element_text(size = 32, face = "bold"),
    axis.text = element_text(size = 26),
    axis.line = element_line(linewidth = 1.2),
    axis.ticks = element_line(linewidth = 1.2)
  )

dev.off()

