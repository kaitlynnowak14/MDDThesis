# ============================================================
# Title: Association Between PRS and Age of Onset (Regression Analysis)
# Dataset: All of Us Final Merged Dataset (EA/MA PRS + Phenotypes + PCs)
#
# Description:
#   - Construct SES composite score
#   - Run univariate linear models
#   - Run nested multivariable models
#   - Compare model fit using LRT and AIC
#
# Output:
#   - Regression summaries
#   - Model comparison statistics
#
# Notes:
#   - Outcome: age of onset (continuous)
#   - Primary predictors: EA PRS, MA PRS
# ============================================================

# =====================================================
# 0. LOAD PACKAGES & SET PATHS
# =====================================================

library(data.table)
library(dplyr)
library(ggplot2)

# =====================================================
# 1. LOAD DATA
# =====================================================

system("gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/final_merged_dataset.csv .")

master_final <- fread("final_merged_dataset.csv")

# =====================================================
# 2. SES SCORE CONSTRUCTION & DATA CLEANING
# =====================================================

# ---- Min-max scaling function ----
min_max <- function(x) {
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}

# ---- Standardize SES Componenets ----
master_final$marital_ses_std   <- min_max(master_final$marital_ord)
master_final$education_ses_std <- min_max(master_final$education_ord)
master_final$employment_ses_std <- min_max(master_final$employment_ord)

# ---- Composite SES Score ----
master_final$ses_combined_raw <-
  master_final$marital_ses_std +
  master_final$education_ses_std +
  master_final$employment_ses_std

master_final$ses_combined <- min_max(master_final$ses_combined_raw)

# ---- Rename Variables for Analysis Consistency ----
master_final <- master_final %>%
  rename(
    ageonset = age_of_onset,   # age of onset
    sex = sex_at_birth,          # rename sex column
  )

# =====================================================
# 3. DESCRIPTIVE STATISTICS (AGE OF ONSET)
# =====================================================
mean_age <- mean(master_final$ageonset, na.rm = TRUE)
sd_age   <- sd(master_final$ageonset, na.rm = TRUE)

cat("Age of onset:", round(mean_age,1), "±", round(sd_age,1), "years\n")

# =====================================================
# 4. CORRECT REFERENCE GROUP FOR SEX
# =====================================================
master_final$sex <- factor(master_final$sex,
                           levels = c("Male", "Female"))

# =====================================================
# 5. UNIVARIATE (UNADJUSTED) MODELS
# =====================================================

# ---- EA PRS ----
model_ea_prs <- lm(ageonset ~ EA_PRS_z,
                   data = master_final)

summary(model_ea_prs)

# ---- MA PRS ----
model_ma_prs <- lm(ageonset ~ MA_PRS_z,
                   data = master_final)

summary(model_ma_prs)

# ---- Sex ----
model_sex <- lm(ageonset ~ sex,
                data = master_final)

summary(model_sex)

# ---- SES ----
model_ses <- lm(ageonset ~ ses_combined,
                data = master_final)

summary(model_ses)

# =====================================================
# 6. NESTED MODELS
# =====================================================

# ---- PCs Only ----
model_PCs <- lm(ageonset ~ pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                  pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                data = master_final)

summary(model_PCs)

# ---- PCs + SES ----
model_PCs_ses <- lm(ageonset ~  pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                      pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16 + 
                      ses_combined,
                    data = master_final)

summary(model_PCs_ses)

# ---- PCs + SES + sex ----
model_PCs_ses_sex <- lm(ageonset ~  pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                          pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16 + 
                          ses_combined + sex,
                        data = master_final)

summary(model_PCs_ses_sex)

# =====================================================
# 7. FULLY ADJUSTED MODELS (PRS MODELS)
# =====================================================

# ---- EA PRS Full Model ----
model_ea_full <- lm(ageonset ~ EA_PRS_z + sex + ses_combined +
                      pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                      pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                    data = master_final)

summary(model_ea_full)

# ---- MA PRS Full Model ----
model_ma_full <- lm(ageonset ~ MA_PRS_z + sex + ses_combined +
                      pc_1 + pc_2 + pc_3 + pc_4 + pc_5 + pc_6 + pc_7 + pc_8 +
                      pc_9 + pc_10 + pc_11 + pc_12 + pc_13 + pc_14 + pc_15 + pc_16,
                    data = master_final)

summary(model_ma_full)

# =====================================================
# 8. MODEL COMPARISON
# =====================================================

# ---- Likelihood Ratio Tests (LRT) ----
# PCs vs PCs + SES
anova(model_PCs, model_PCs_ses)

# PCs + SES vs PCs + SES + Sex
anova(model_PCs_ses, model_PCs_ses_sex)

# Full EA model vs reduced model
model_reduced_ea <- model_PCs_ses_sex
anova(model_reduced_ea, model_ea_full)

# Full MA Model vs reduced model
model_reduced_ma <- model_PCs_ses_sex
anova(model_reduced_ma, model_ma_full)

# ---- AIC Comparison ----
AIC(model_PCs,
    model_PCs_ses,
    model_PCs_ses_sex,
    model_ea_full,
    model_ma_full)
