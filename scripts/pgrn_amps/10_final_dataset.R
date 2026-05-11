# ============================================================================
# Title: PGRN-AMPS Phenotype Standardization & Final Dataset Assembly
# Dataset: PGRN-AMPS Integrated Genotype + Phenotype Dataset
#
# Description:
#   - Recodes demographic and SES phenotype variables
#   - Constructs standardized SES composite variables
#   - Generates demographics summary table
#   - Combines EA and MA PRS datasets into final master file
#
# Output:
#   master_EA_final.csv
#   master_MA_final.csv
#   Table1_Demographics.csv
#   Master_Final.csv
#
# Notes:
#   - SES variables are min–max scaled and equally weighted
#   - Final dataset contains both EA and MA PRS measures
#   - Demographics table generated from EA master dataset
# ============================================================================

# ============================================================
# 0. LOAD LIBRARIES & SET PATHS
# ============================================================

library(dplyr)

save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"

# ============================================================
# 1. EA MASTER FILE STANDARDIZATION
# ============================================================

# ---- Backup EA Master Dataset ----
master_EA_clean_copy <- master_EA_clean

# ---- Recode Gender ----
master_EA_clean$gender <- ifelse(master_EA_clean$gender == "M", 0,
                                         ifelse(master_EA_clean$gender == "F", 1, NA))


# ---- Recode Marital Status ----
master_EA_clean$maritalstatus <- ifelse(master_EA_clean$maritalstatus %in% c("S"), 0,
                                          ifelse(master_EA_clean$maritalstatus %in% c("D","W","X"), 1,
                                                 ifelse(master_EA_clean$maritalstatus %in% c("M","C","P"), 2, NA)))
  

# ---- Recode Education ----
master_EA_clean$highdegree <- ifelse(master_EA_clean$highdegree == 1, 0,
                                            ifelse(master_EA_clean$highdegree %in% c(2,3), 1,
                                                   ifelse(master_EA_clean$highdegree %in% c(4,5), 2,
                                                          ifelse(master_EA_clean$highdegree == 6, 3,
                                                                 ifelse(master_EA_clean$highdegree %in% c(7,8), 4, NA)))))


# ---- Recode Employment ----
master_EA_clean$currentempstat <- ifelse(master_EA_clean$currentempstat %in% c(3,4,5), 2,   # Employed
                                  ifelse(master_EA_clean$currentempstat == 2, 1,      # Unemployed looking
                                         0))     # Out of workforce (retired, unemployed not looking)


# ---- Remove Current Student Variable ----
master_EA_clean$currentstudent <- NULL


# ============================================================
# 2. SES CONSTRUCTION
# ============================================================

# ---- Min-Max Scaling Function ----
min_max <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}

# ---- Standardize Each SES Component ----
master_EA_clean$marital_ses_std <- min_max(master_EA_clean$maritalstatus)
master_EA_clean$education_ses_std <- min_max(master_EA_clean$highdegree)
master_EA_clean$employment_ses_std <- min_max(master_EA_clean$currentempstat)

# ---- Create Combined SES Score ----
master_EA_clean$ses_combined_raw <-
  master_EA_clean$marital_ses_std +
  master_EA_clean$education_ses_std +
  master_EA_clean$employment_ses_std

# ---- Final SES Score (0-1 Scaled) ----
master_EA_clean$ses_combined <- min_max(master_EA_clean$ses_combined_raw)


# ---- Save EA Final dataset ----
write.csv(master_EA_clean, file = file.path(save_path, "master_EA_final.csv"),
          row.names = FALSE)

# ============================================================
# 3. MA MASTER FILE STANDARDIZATION
# ============================================================

# ---- Load MA Dataset ----
master_MA_clean <- read.csv(file.path(save_path, "master_MA.csv"))

# ---- Backup MA Master Dataset ----
master_MA_clean_copy <- master_MA_clean

# ---- Recode Gender ----
master_MA_clean$gender <- ifelse(master_MA_clean$gender == "M", 0,
                                 ifelse(master_MA_clean$gender == "F", 1, NA))

# ---- Recode Marital Status ----
master_MA_clean$maritalstatus <- ifelse(master_MA_clean$maritalstatus %in% c("S"), 0,
                                        ifelse(master_MA_clean$maritalstatus %in% c("D","W","X"), 1,
                                               ifelse(master_MA_clean$maritalstatus %in% c("M","C","P"), 2, NA)))


# ---- Recode Marital Status ----
master_MA_clean$highdegree <- ifelse(master_MA_clean$highdegree == 1, 0,
                                     ifelse(master_MA_clean$highdegree %in% c(2,3), 1,
                                            ifelse(master_MA_clean$highdegree %in% c(4,5), 2,
                                                   ifelse(master_MA_clean$highdegree == 6, 3,
                                                          ifelse(master_MA_clean$highdegree %in% c(7,8), 4, NA)))))

# ---- Recode Education ----
master_MA_clean$currentempstat <- ifelse(master_MA_clean$currentempstat %in% c(3,4,5), 2,   # Employed
                                         ifelse(master_MA_clean$currentempstat == 2, 1,      # Unemployed looking
                                                0))     # Out of workforce (retired, unemployed not looking)


# ---- Remove Current Student Variable ----
master_MA_clean$currentstudent <- NULL


# ---- Save MA Final Dataset ----
write.csv(master_MA_clean, file = file.path(save_path, "master_MA_final.csv"),
          row.names = FALSE)

# ============================================================
# 4. COMBINE EA + MA FINAL DATASETS
# ============================================================

# Load Datasets
master_MA_final <- read.csv(file.path(save_path, "master_MA_final.csv"))

# Create Master Dataset 
master_final <- master_EA_final

# Add MA PRS Columns
master_final$MA_PRS_total <- master_MA_final$MA_PRS_total
master_final$MA_PRS_z <- master_MA_final$MA_PRS_z

# Reorder PRS Columns
master_final <- master_final[, c(
  "SUBJID", "FID", "IID",
  "EA_PRS_total", "EA_PRS_z",
  "MA_PRS_total", "MA_PRS_z",
  setdiff(names(master_final),
          c("SUBJID", "FID", "IID",
            "EA_PRS_total", "EA_PRS_z",
            "MA_PRS_total", "MA_PRS_z"))
)]

# Save Final Dataset
write.csv(master_final,file = file.path(save_path, "Master_Final.csv"),
          row.names = FALSE)
