# ============================================================================
# Title: PGRN-AMPS Final Master Table Construction
# Dataset: PGRN-AMPS Genotype + Phenotype Integrated Dataset
#
# Description:
#   - Merges cleaned phenotype data with PRS outputs (EA and MA)
#   - Restricts sample to individuals passing genomic QC
#   - Constructs final analysis-ready master datasets
#   - Standardizes PRS scores (z-transformation)
#
# Output:
#   Master_EA.csv
#   Master_MA.csv
#
# Notes:
#   - Uses PLINK .fam files to define QC-passed individuals
#   - Ensures FID/IID consistency across phenotype and genotype layers
# ============================================================================

# ============================================================
# 0. LOAD LIBRARIES & SET PATHS
# ============================================================

library(tidyverse)

pheno_path <- "/Users/knowak/Desktop/PGRN-AMPS/Files Needed for Analyses"
save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"

EA_genome_path <- "/Users/knowak/Desktop/PGRN-AMPS/EA Files"
MA_genome_path <- "/Users/knowak/Desktop/PGRN-AMPS/MA Files"

# ============================================================
# 1. LOAD AND FILTER PHENOTYPE DATA (QC-PASSED SAMPLE)
# ============================================================

# ---- Load phenotype dataset ----
phenos_clean <- read_csv(file.path(save_path, "PGRN_AMPS_Phenotypes_Clean.csv"))

# ---- Create PLINK-Compatible FID/IID ----
phenos_clean <- phenos_clean %>%
  mutate(FID = paste0(SUBJID, "_", SUBJID),
         IID = paste0(SUBJID, "_", SUBJID))

# ---- Load QC-Passed Individuals ----
fam <- read_table(file.path(EA_genome_path, "EA_autosomes.fam"), col_names = FALSE)
colnames(fam) <- c("FID", "IID", "PID", "MID", "SEX", "PHENO")

# ---- Restrict Phenotype Table to QC-Passed Samples ----
phenos_qc <- phenos_clean %>%
  semi_join(fam, by = c("FID", "IID"))

# ============================================================
# 2. EA MASTER TABLE
# ============================================================

# ---- Merge PRS & Phenotype Data ----
master_EA <- EA_PRS_combined %>%
  left_join(phenos_qc, by = c("FID", "IID"))

# ---- Clean & Reorder Variables ----
master_EA_clean <- master_EA %>%
  select(SUBJID, FID, IID, everything()) %>%     # move FID and IID to front
  select(-dbGaP_Subject_ID, -EA_PRS_autosomes, -EA_PRS_chrX)      # remove unneeded columns

# ---- Standardize PRS (z-score) ----
master_EA_clean <- master_EA_clean %>%
  mutate(EA_PRS_z = as.numeric(scale(EA_PRS_total))) %>%
  relocate(EA_PRS_z, .after = EA_PRS_total)

# ---- Save EA Master dataset ----
write_csv(master_EA_clean, file.path(save_path, "Master_EA.csv"))

# ============================================================
# 3. MA MASTER TABLE
# ============================================================

# ---- Merge PRS & Phenotype Data ----
master_MA <- MA_PRS_combined %>%
  left_join(phenos_qc, by = c("FID", "IID"))

# ---- Clean & Reorder Variables ----
master_MA_clean <- master_MA %>%
  select(SUBJID, FID, IID, everything()) %>%     # move FID and IID to front
  select(-dbGaP_Subject_ID, -MA_PRS_autosomes, -MA_PRS_chrX)      # remove unneeded columns

# ---- Standardize PRS (z-score) ----
master_MA_clean <- master_MA_clean %>%
  mutate(MA_PRS_z = as.numeric(scale(MA_PRS_total))) %>%
  relocate(MA_PRS_z, .after = MA_PRS_total)

# ---- Save EA Master dataset ----
write_csv(master_MA_clean, file.path(save_path, "Master_MA.csv"))
