# ============================================================
# Title: dbGaP Phenotype Cleaning Pipeline (PGRN-AMPS Cohort)
# Dataset: PGRN-AMPS dbGaP Subject Phenotypes (phs000670)
#
# Description:
#   - Loads raw dbGaP phenotype file
#   - Filters excluded and low-quality participants
#   - Selecys analytic variables
#   - Removes missing data
#   - Exports clean phenotype dataset for downstream analyses
#
# Output:
#   PGRN_AMPS_Phenotypes_clean.csv
#
# Notes: 
#   - Ensures harmonized and analytic cohort for PRS + phenotype models
#   - Removes "Other" race and unknown marital status ("U")
# =============================================================

# =====================================================
# 1. LOAD LIBRARIES
# =====================================================

library(readr)
library(dplyr)
library(tidyr)
library(XML)

# =====================================================
# 2. DEFINE PATHS
# =====================================================

base_path <- "/Users/knowak/Desktop/PGRN-AMPS/Files Needed for Analyses"
save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"

# =====================================================
# 3. LOAD RAW PHENOTYPE DATA
# =====================================================

phenos <- read_tsv(
  gzfile(file.path(base_path, 
                   "phs000670.v1.pht003556.v1.p1.c1.PGRN_AMPS_Subject_Phenotypes.HMB.txt.gz")),
  skip = 10   
)

# =====================================================
# 4. FILTER PARTICIPANTS
# =====================================================

phenos_filtered <- phenos %>%
  filter(IsExcluded == "No") %>%
  filter(lookup.race != "Other") %>%
  filter(maritalstatus != "U")

# =====================================================
# 5. SELECT ANALYTIC VARIABLES
# =====================================================

columns_needed <- c("dbGaP_Subject_ID", "SUBJID", "lookup.race", "race", "gender", "age", "ageonset", "highdegree",
                    "currentempstat", "currentstudent", "maritalstatus", "EVEC.1", "EVEC.2", 
                    "EVEC.3", "EVEC.4")

phenos_clean <- phenos_filtered %>%
  select(all_of(columns_needed))

# =====================================================
# 6. REMOVE MISSING DATA
# =====================================================

phenos_clean <- phenos_clean %>%
  drop_na()  # removes any participant with NA in any of the selected columns

# 6. Save clean phenotype for analyses ####
write.csv(phenos_clean, file.path(save_path, "PGRN_AMPS_Phenotypes_Clean.csv"), row.names = FALSE)
