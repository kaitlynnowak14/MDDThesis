##### PGRN-AMPS Analyses #####

# 1. Load packages and paths if necessary ####
library(ggplot2)

# 2. Load files if necessary ####
save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"

# 3. Summarize master final ####
master_final <- read.csv(file.path(save_path, "master_final.csv"))
str(master_final)
summary(master_final)

# 4. Descriptive statistics for age of onset ####
mean_age <- mean(master_final$ageonset, na.rm = TRUE)
sd_age   <- sd(master_final$ageonset, na.rm = TRUE)

cat("Age of onset:", round(mean_age,1), "±", round(sd_age,1), "years\n")

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

# ======================= Univariate Unadjusted Models =========================

# 1. EA PRS Only ####
model_ea_prs <- lm(ageonset ~ EA_PRS_z,
                data = master_final)

summary(model_ea_prs)

# 2. MA PRS Only ####
model_ma_prs <- lm(ageonset ~ MA_PRS_z,
                data = master_final)

summary(model_ma_prs)

# 3. Sex Only ####
model_sex <- lm(ageonset ~ sex,
                data = master_final)

summary(model_sex)

# 4. SES Only ####
model_ses <- lm(ageonset ~ ses_combined,
                data = master_final)

summary(model_ses)

# ============================ Nested Models ===================================

# 1. PCs Only ####
model_PCs <- lm(ageonset ~ EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                data = master_final)

summary(model_PCs)

# 2. PCs + SES ####
model_PCs_ses <- lm(ageonset ~ EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4 + ses_combined,
                data = master_final)

summary(model_PCs_ses)

# 3. PCs + SES + sex ####
model_PCs_ses_sex <- lm(ageonset ~ EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4 + 
                          ses_combined + sex,
                    data = master_final)

summary(model_PCs_ses_sex)

# 4. Fully Adjusted EA Model (PCs + SES + sex + EA PRS) ####
model_ea_full <- lm(ageonset ~ EA_PRS_z + sex + ses_combined +
                      EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                    data = master_final)

summary(model_ea_full)

# 5. Fully Adjusted MA Model (PCs + SES + sex + MA PRS) ####
model_ma_full <- lm(ageonset ~ MA_PRS_z + sex + ses_combined +
                      EVEC.1 + EVEC.2 + EVEC.3 + EVEC.4,
                    data = master_final)

summary(model_ma_full)

# ======================== Comparing Models ====================================

# 1. Main effects likelihood ratio test (LRT)
## 1.1. PCs only vs + SES
anova(model_PCs, model_PCs_ses)

## 1.2. + SES vs + SES + Sex
anova(model_PCs_ses, model_PCs_ses_sex)

## 1.3.1. Full EA model vs reduced (no PRS)
model_reduced_ea <- model_PCs_ses_sex
anova(model_reduced_ea, model_ea_full)

## 1.3.2. Full MA model vs reduced (no PRS)
model_reduced_ma <- model_PCs_ses_sex
anova(model_reduced_ma, model_ma_full)

# 2. Akaike Information Criterion (AIC) model comparison (lower AIC = better model)
AIC(model_PCs,
    model_PCs_ses,
    model_PCs_ses_sex,
    model_ea_full,
    model_ma_full)
