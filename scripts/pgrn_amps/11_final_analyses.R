# ============================================================================
# Title: PGRN-AMPS Statistical Analyses
# Dataset: PGRN-AMPS Cohort
#
# Description:
#   - Load finalized analytic dataset
#   - Perform descriptive analyses and phenotype recoding
#   - Run univariate and fully adjusted regression models
#   - Compare nested models using likelihood ratio tests and AIC
#
# Output:
#   Linear regression model summaries
#   Model comparison statistics (LRT + AIC)
#
# Notes:
#   - Outcome variable = age of MDD onset
#   - Covariates include sex, SES, and ancestry principal components
#   - EA and MA PRS analyzed in separate fully adjusted models

# =====================================================
# 1. LOAD PACKAGES & FILES
# =====================================================

library(ggplot2)

save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"

# ---- Load Final Analytic Dataset ----
master_final <- read.csv(file.path(save_path, "master_final.csv"))

# Inspect dataset structure
str(master_final)
summary(master_final)

# =====================================================
# 2. DESCRIPTIVE STATISTICS
# =====================================================

# ---- Age of Onset Summary Statistics ----
mean_age <- mean(master_final$ageonset, na.rm = TRUE)
sd_age   <- sd(master_final$ageonset, na.rm = TRUE)

cat("Age of onset:", round(mean_age,1), "±", round(sd_age,1), "years\n")

# =====================================================
# 3. DATA CLEANING & VARIABLE RECODING
# =====================================================

# ---- Recode Gender/Sex ----
master_final$gender <- factor(master_final$gender,
                              levels = c(0,1),
                              labels = c("Male","Female"))

# Rename variable gender -> sex
names(master_final)[names(master_final) == "gender"] <- "sex"

# Recode race as factor
master_final$race <- as.factor(master_final$race)

# Confirm structure updated
str(master_final)

# =====================================================
# 4. UNIVARIATE UNADJUSTED MODELS
# =====================================================

# ---- EA PRS Only ----
model_ea_prs <- lm(ageonset ~ EA_PRS_z,
                data = master_final)

summary(model_ea_prs)

# ---- MA PRS Only ----
model_ma_prs <- lm(ageonset ~ MA_PRS_z,
                data = master_final)

summary(model_ma_prs)

# ---- Sex Only ----
model_sex <- lm(ageonset ~ sex,
                data = master_final)

summary(model_sex)

# ---- SES Only ----
model_ses <- lm(ageonset ~ ses_combined,
                data = master_final)

summary(model_ses)

# =====================================================
# 5. NESTED COVARIATE MODELS
# =====================================================

# ---- PCs Only ----
model_PCs <- lm(ageonset ~ EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                data = master_final)

summary(model_PCs)

# ---- PCs + SES ----
model_PCs_ses <- lm(ageonset ~ EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4 + ses_combined,
                data = master_final)

summary(model_PCs_ses)

# ---- PCs + SES + Sex ----
model_PCs_ses_sex <- lm(ageonset ~ EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4 + 
                          ses_combined + sex,
                    data = master_final)

summary(model_PCs_ses_sex)


# =====================================================
# 6. FULLY ADJUSTED PRS MODELS
# =====================================================

# ---- Fully Adjusted EA Model (PCs + SES + sex + EA PRS) ----
model_ea_full <- lm(ageonset ~ EA_PRS_z + sex + ses_combined +
                      EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                    data = master_final)

summary(model_ea_full)

# ---- Fully Adjusted MA Model (PCs + SES + sex + MA PRS) ----
model_ma_full <- lm(ageonset ~ MA_PRS_z + sex + ses_combined +
                      EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                    data = master_final)

summary(model_ma_full)

# =====================================================
# 7. MODEL COMPARISONS
# =====================================================

# ---- Likelihood Ratio Tests (LRT) ----
# PCs only vs + SES
anova(model_PCs, model_PCs_ses)

# PCs + SES vs PCs + SES + Sex
anova(model_PCs_ses, model_PCs_ses_sex)

# Reduced EA Model vs Full EA PRS Model
model_reduced_ea <- model_PCs_ses_sex
anova(model_reduced_ea, model_ea_full)

# Reduced MA Model vs Full MA PRS Model
model_reduced_ma <- model_PCs_ses_sex
anova(model_reduced_ma, model_ma_full)

# ---- AIC ----
AIC(model_PCs,
    model_PCs_ses,
    model_PCs_ses_sex,
    model_ea_full,
    model_ma_full)
