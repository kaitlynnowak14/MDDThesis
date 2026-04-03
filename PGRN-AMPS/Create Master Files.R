##### Combining to Final Table #####

# 0. Load libraries & set paths ####
library(tidyverse)

pheno_path <- "/Users/knowak/Desktop/PGRN-AMPS/Files Needed for Analyses"
save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"
EA_genome_path <- "/Users/knowak/Desktop/PGRN-AMPS/EA Files"
MA_genome_path <- "/Users/knowak/Desktop/PGRN-AMPS/MA Files"

# 1. Limit phenotype table to those who passed genomic QC ####
## 1.1 Load phenotype table
phenos_clean <- read_csv(file.path(save_path, "PGRN_AMPS_Phenotypes_Clean.csv"))

### 1.1.1 Create FID/IID columns to match PLINK double-id
phenos_clean <- phenos_clean %>%
  mutate(FID = paste0(SUBJID, "_", SUBJID),
         IID = paste0(SUBJID, "_", SUBJID))

## 1.2 Load list of participants who passed QC (can use EA or MA here)
fam <- read_table(file.path(EA_genome_path, "EA_autosomes.fam"), col_names = FALSE)
colnames(fam) <- c("FID", "IID", "PID", "MID", "SEX", "PHENO")

## 1.3 Filter phenotype table to only include QC-passed participants
phenos_qc <- phenos_clean %>%
  semi_join(fam, by = c("FID", "IID"))


# ----------------------
# Create EA Master Table
# ----------------------
master_EA <- EA_PRS_combined %>%
  left_join(phenos_qc, by = c("FID", "IID"))

master_EA_clean <- master_EA %>%
  select(SUBJID, FID, IID, everything()) %>%     # move FID and IID to front
  select(-dbGaP_Subject_ID, -EA_PRS_autosomes, -EA_PRS_chrX)      # remove unneeded columns

# Standardize PRS Score
master_EA_clean <- master_EA_clean %>%
  mutate(EA_PRS_z = as.numeric(scale(EA_PRS_total))) %>%
  relocate(EA_PRS_z, .after = EA_PRS_total)

write_csv(master_EA_clean, file.path(save_path, "Master_EA.csv"))

# ----------------------
# Create MA Master Table
# ----------------------
master_MA <- MA_PRS_combined %>%
  left_join(phenos_qc, by = c("FID", "IID"))

master_MA_clean <- master_MA %>%
  select(SUBJID, FID, IID, everything()) %>%     # move FID and IID to front
  select(-dbGaP_Subject_ID, -MA_PRS_autosomes, -MA_PRS_chrX)      # remove unneeded columns

# Standardize PRS Score
master_MA_clean <- master_MA_clean %>%
  mutate(MA_PRS_z = as.numeric(scale(MA_PRS_total))) %>%
  relocate(MA_PRS_z, .after = MA_PRS_total)

write_csv(master_MA_clean, file.path(save_path, "Master_MA.csv"))
