##### EA Analyses #####

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
model1 <- lm(ageonset ~ EA_PRS_z +
               EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
             data = master_final)

summary(model1)

# 7. Model 2: PRS + gender + SES + PCs ####
model2 <- lm(ageonset ~ EA_PRS_z +
               gender +
               ses_combined +
               EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
             data = master_final)

summary(model2)

# 8. Model 3: PRS x Sex interaction ####
model3 <- lm(ageonset ~ EA_PRS_z * gender +
               ses_combined +
               EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
             data = master_final)

summary(model3)

# 9. Model 4: PRS x SES interaction ####
model4 <- lm(ageonset ~ EA_PRS_z * ses_combined +
               gender +
               EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
             data = master_final)

summary(model4)

# 10. Model 5: Full model with both interaction terms ####
model_full <- lm(ageonset ~ EA_PRS_z * gender +
                   EA_PRS_z * ses_combined +
                   gender +
                   ses_combined +
                   EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                 data = master_final)

summary(model_full)

# 11. Test gene-environment correlation ####
cor.test(master_final$EA_PRS_z,
         master_final$ses_combined)

# 12. Test PRS & Sex
model6 <- lm(ageonset ~ EA_PRS_z +
               gender +
               EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
             data = master_final)

summary(model6)

# 13. Test PRS & SES
model7 <- lm(ageonset ~ EA_PRS_z +
               ses_combined +
               EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
             data = master_final)

summary(model7)

# ===================== Creating regression table of results ===================

# Load packages
install.packages("modelsummary")
library(modelsummary)

# Create table
modelsummary(
  list(
    "Additive Model" = model2,
    "Interaction Model" = model_full
  ),
  estimate = "{estimate}",
  statistic = c("{std.error}", "{p.value}"),
  coef_map = c(
    "EA_PRS_z" = "Polygenic Risk Score (z)",
    "genderFemale" = "Female (vs Male)",
    "ses_combined" = "Socioeconomic Status (0–1)",
    "EA_PRS_z:genderFemale" = "PRS × Female",
    "EA_PRS_z:ses_combined" = "PRS × SES",
    "EVEC.1" = "PC1",
    "EVEC.2" = "PC2",
    "EVEC.3" = "PC3",
    "EVEC.4" = "PC4",
    "(Intercept)" = "Intercept"
  ),
  gof_map = data.frame(
    raw = c("r.squared", "adj.r.squared"),
    clean = c("R²", "Adjusted R²"),
    fmt = 3
  ),
  stars = FALSE,
  output = "markdown"
)


# ======================== Creating Figures ====================================

# 1. Figure 1: PRS & Age of Onset ####
model1_simple <- lm(ageonset ~ EA_PRS_z, data = master_final)
summary(model1_simple)$r.squared

# Extract R2
r2_value <- summary(model1_simple)$r.squared
r2_label <- paste0("Unadjusted R² = ", round(r2_value, 3))

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

# 3. Figure 3: Sex Differences in Age of Onset
sex_summary <- master_final %>%
  group_by(gender) %>%
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

p3 <- ggplot(master_final, aes(x = gender, y = ageonset)) + 
  
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

ggsave("Sex_AOO_poster.svg",
       plot = p3,
       width = 11,
       height = 12,
       units = "in")

# 4. Figure 4: EA PRS x Sex
ggplot(master_final, aes(x = EA_PRS_z, y = ageonset, color = gender)) +
  geom_point(alpha = 0.4, color = "steelblue") +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1.2,
              aes(color = gender)) +
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
  MA_PRS_z = seq(min(master_final$MA_PRS_z, na.rm = TRUE),
                 max(master_final$MA_PRS_z, na.rm = TRUE),
                 length.out = 100),
  gender = "Male",
  ses_combined = mean(master_final$ses_combined, na.rm = TRUE),
  EVEC.1 = 0,
  EVEC.2 = 0,
  EVEC.3 = 0,
  EVEC.4 = 0
)

# Generate predictions with standard errors
predictions <- predict(model2_MA, newdata, se.fit = TRUE)

# Add predictions + CI to newdata
newdata$pred <- predictions$fit
newdata$lower <- predictions$fit - 1.96 * predictions$se.fit
newdata$upper <- predictions$fit + 1.96 * predictions$se.fit

# Extract R2 from additive model
r2_value <- summary(model2_MA)$r.squared
r2_label <- paste0("R² = ", round(r2_value, 3))

p2 <- ggplot() +
  geom_point(data = master_final,
             aes(x = MA_PRS_z, y = ageonset),
             alpha = 0.5, color = "forestgreen", size = 3) +
  
  geom_ribbon(data = newdata,
              aes(x = MA_PRS_z,
                  ymin = lower,
                  ymax = upper),
              fill = "black",
              alpha = 0.15) +
  
  geom_line(data = newdata,
            aes(x = MA_PRS_z, y = pred),
            color = "black",
            linewidth = 1.6) +
  
  annotate("text",
           x = Inf, y = -Inf,
           label = r2_label,
           hjust = 1.1, vjust = -0.6,
           size = 8) +   # scaled for poster
  
  labs(
    title = "Adjusted Association Between MA PRS\nand Age of MDD Onset",
    x = "MA Polygenic Risk Score (Z)",
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

ggsave("MA_PRS_AOO_poster.svg",
       plot = p2,
       width = 11,
       height = 12,
       units = "in")

# SES and AOO for poster
p <- ggplot(master_final, aes(x = ses_combined, y = ageonset)) +
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

ggsave("SES_AOO_poster.svg",
       plot = p,
       width = 11,
       height = 12,
       units = "in")