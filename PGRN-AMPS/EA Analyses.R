##### EA Analyses #####

# 1. Load packages and paths if necessary ####
library(ggplot2)

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
hist(master_final$ageonset,
     breaks = 20,
     xlab = "Age of Onset (Years)",
     main = "PGRN-AMPS: Distribution of Age of Onset",
     col = col_other,
     border = "white")

# 5. Data Cleaning ####
# Recode gender (0 = Male, 1 = Female)
master_final$gender <- factor(master_final$gender,
                              levels = c(0,1),
                              labels = c("Male","Female"))

# Rename variable gender -> sex
names(master_final)[names(master_final) == "gender"] <- "sex"

# Recode race as factor
master_final$race <- as.factor(master_final$race)

# Check structure again
str(master_final)

# ========================== EA Modeling ====================================

# 0. Covariates Only ####
model_cov <- lm(ageonset ~ EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                data = master_final)

summary(model_cov)

# 1. PRS Only ####
model_prs <- lm(ageonset ~ EA_PRS_z +
                  EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                data = master_final)

summary(model_prs)

# 2. Sex Only ####
model_sex <- lm(ageonset ~ sex +
                  EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                data = master_final)

summary(model_sex)

# 3. SES Only ####
model_ses <- lm(ageonset ~ ses_combined +
                  EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                data = master_final)

summary(model_ses)

# 4. Additive Model (no interactions) ####
model_additive <- lm(ageonset ~ EA_PRS_z + sex + ses_combined +
                       EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                     data = master_final)

summary(model_additive)

# 5. PRS x Sex Interaction ####
model_prs_sex <- lm(ageonset ~ EA_PRS_z * sex +
                      ses_combined +
                      EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                    data = master_final)

summary(model_prs_sex)

# 6. PRS x SES Interaction ####
model_prs_ses <- lm(ageonset ~ EA_PRS_z * ses_combined +
                      sex +
                      EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                    data = master_final)

summary(model_prs_ses)

# 7. Sex x SES Interaction ####
model_sex_ses <- lm(ageonset ~ sex * ses_combined +
                      EA_PRS_z +
                      EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                    data = master_final)

summary(model_sex_ses)

# 8. Full 2-Way Interaction Model ####
model_full_2way <- lm(ageonset ~ EA_PRS_z * sex +
                        EA_PRS_z * ses_combined +
                        sex * ses_combined +
                        EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                      data = master_final)

summary(model_full_2way)

# 9. Full 3-Way Interaction Model ####
model_full_3way <- lm(ageonset ~ EA_PRS_z * sex * ses_combined +
                        EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                      data = master_final)

summary(model_full_3way)

# ======================== Comparing Models ====================================

# 1. Main effects likelihood ratio test (LRT)
anova(model_cov, model_prs) 
anova(model_cov, model_sex)
anova(model_cov, model_ses)
anova(model_prs, model_additive)

# 2. Interaction terms LRT
anova(model_additive, model_prs_sex)
anova(model_additive, model_prs_ses)
anova(model_additive, model_sex_ses)

# 3. Higher-order models LRT
anova(model_additive, model_full_2way)
anova(model_full_2way, model_full_3way)

# 4. Akaike Information Criterion (AIC) model comparison (lower AIC = better model)
AIC(model_cov, model_prs, model_additive, model_full_2way, model_full_3way)

AIC(model_additive, model_prs_sex, model_prs_ses, model_sex_ses,
    model_full_2way)

# 5. Bayesian Information Criterion (BIC) model comparison
BIC(model_cov, model_prs, model_additive, model_full_2way, model_full_3way)

BIC(model_additive, model_prs_sex, model_prs_ses, model_sex_ses,
    model_full_2way)

# 6. Root Mean Squared Error (RMSE) (measured prediciton error)
rmse <- function(model) {
  sqrt(mean(residuals(model)^2))
}

rmse_values <- data.frame(
  Model = c("Covariates", "PRS", "Additive", "Full 2-way", "Full 3-way"),
  RMSE = c(
    rmse(model_cov),
    rmse(model_prs),
    rmse(model_additive),
    rmse(model_full_2way),
    rmse(model_full_3way)
  )
)

rmse_values

# ======================== Creating Figures ====================================

# 0. Set Theme
# PRS / ancestry colors (PRIMARY COMPARISON)
col_EA <- "steelblue"
col_MA <- "#B22222"

# Covariates / non-primary grouping
col_other <- "grey60"

# Sex (secondary grouping — keep neutral)
col_male <- "grey30"
col_female <- "grey70"

# Dataset label
dataset_label <- "PGRN-AMPS"

# Global theme
theme_thesis <- theme_classic(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.line = element_line(linewidth = 0.8)
  )

# 1. Figure 1: EA PRS & Age of Onset ####
model_prs_simple <- lm(ageonset ~ EA_PRS_z, data = master_final)
r2_prs <- summary(model_prs_simple)$r.squared

ggplot(master_final, aes(x = EA_PRS_z, y = ageonset)) +
  geom_point(alpha = 0.5, size = 1.5, color = col_EA) +
  geom_smooth(method = "lm", se = TRUE, color = col_other, linewidth = 1.2) +
  annotate("text",
           x = Inf, y = -Inf,
           label = paste0("R² = ", round(r2_prs, 3)),
           hjust = 1.1, vjust = -0.8, size = 4) +
  labs(
    title = paste0(dataset_label, ": EA Polygenic Risk Score and Age of MDD Onset"),
    x = "EA Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis

# 2. Figure 2: SES & Age of Onset ####
model_ses_simple <- lm(ageonset ~ ses_combined, data = master_final)
r2_ses <- summary(model_ses_simple)$r.squared

ggplot(master_final, aes(x = ses_combined, y = ageonset)) +
  geom_point(alpha = 0.5, size = 1.5, color = col_other) +
  geom_smooth(method = "lm", se = TRUE, color = col_other, linewidth = 1.2) +
  annotate("text",
            x = Inf, y = -Inf,
           label = paste0("R² = ", round(r2_ses, 3)),
           hjust = 1.1, vjust = -0.8, size = 4) +
  labs(
    title = paste0(dataset_label, ": Socioeconomic Status and Age of MDD Onset"),
    x = "Socioeconomic Status (0–1 Scaled)",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis

# 3. Figure 3: Sex Differences
ggplot(master_final, aes(x = sex, y = ageonset)) +
  geom_boxplot(fill = col_other, alpha = 0.6, linewidth = 1) +
  labs(
    title = paste0(dataset_label, ": Sex Differences in Age of MDD Onset"),
    x = "Sex",
    y = "Age of MDD Onset (Years)"
  ) +
  theme_thesis

# 4. Figure 4: Sex x SES Interaction
model_sex_ses <- lm(ageonset ~ sex * ses_combined +
                      EA_PRS_z + EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                    data = master_final)

newdata <- expand.grid(
  ses_combined = seq(min(master_final$ses_combined, na.rm = TRUE),
                     max(master_final$ses_combined, na.rm = TRUE),
                     length.out = 100),
  sex = unique(master_final$sex),
  EA_PRS_z = 0,
  EVEC.1 = 0, EVEC.2 = 0, EVEC.3 = 0, EVEC.4 = 0
)

pred <- predict(model_sex_ses, newdata, se.fit = TRUE)
newdata$fit <- pred$fit
newdata$lower <- pred$fit - 1.96 * pred$se.fit
newdata$upper <- pred$fit + 1.96 * pred$se.fit

ggplot(newdata, aes(x = ses_combined, y = fit, color = sex, fill = sex)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.15, color = NA) +
  geom_line(linewidth = 1.3) +
  
  scale_color_manual(values = c(
    "Male" = col_male,
    "Female" = col_female
  )) +
  scale_fill_manual(values = c(
    "Male" = col_male,
    "Female" = col_female
  )) +
  
  labs(
    title = paste0(dataset_label, ": Sex × Socioeconomic Status Interaction on Age of MDD Onset"),
    x = "Socioeconomic Status (0–1 scaled)",
    y = "Predicted Age of MDD Onset (Years)",
    color = "Sex",
    fill = "Sex"
  ) +
  theme_thesis

# 5. Figure 5: EA PRS x Sex
ggplot(master_final, aes(x = EA_PRS_z, y = ageonset)) +
  
  # MA PRS distribution (background signal)
  geom_point(alpha = 0.4, color = col_EA) +
  
  # sex-specific fitted lines
  geom_smooth(aes(color = sex), method = "lm", se = FALSE, linewidth = 1.2) +
  
  scale_color_manual(values = c(
    "Male" = col_male,
    "Female" = col_female
  )) +
  
  labs(
    title = paste0(dataset_label, ": EA PRS × Sex Interaction on Age of MDD Onset"),
    x = "EA Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)",
    color = "Sex"
  ) +
  
  theme_thesis

# Figure 6: EA PRS x SES ####
master_final$ses_group <- ifelse(
  master_final$ses_combined >= median(master_final$ses_combined, na.rm = TRUE),
  "Higher SES",
  "Lower SES"
)

ggplot(master_final, aes(x = EA_PRS_z, y = ageonset)) +
  
  geom_point(alpha = 0.35, color = col_EA) +
  
  geom_smooth(
    aes(color = ses_group),
    method = "lm",
    se = FALSE,
    linewidth = 1.2
  ) +
  
  scale_color_manual(values = c(
    "Lower SES" = col_other,
    "Higher SES" = "grey30"
  )) +
  
  labs(
    title = paste0(dataset_label, ": EA PRS × SES Stratified Association on Age of MDD Onset"),
    x = "EA Polygenic Risk Score (Z)",
    y = "Age of MDD Onset (Years)",
    color = "SES Group"
  ) +
  
  theme_thesis
