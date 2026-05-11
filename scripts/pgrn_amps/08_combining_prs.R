# ============================================================================
# Title: PGRN-AMPS PRS Combination Pipeline (Autosomes + Chr X)
# Dataset: PGRN-AMPS Genotype-Derived PRS Outputs
#
# Description:
#   - Combines autosomal and chromosome X PRS scores
#   - Generates final total PRS variables for EA and MA models
#   - Prepares cleaned PRS datasets for downstream analyses
#
# Output:
#   PRS_EA_combined.csv
#   PRS_MA_combined.csv
#
# Notes:
#   - Requires PLINK-generated .profile files
#   - Ensures consistent FID/IID merging across chromosomes
# ============================================================================

# ============================================================
# 0. LOAD LIBRARIES & SET PATH
# ============================================================

library(tidyverse)

path <- "/Users/knowak/Desktop/PRS Scores Final"

# ============================================================
# 1. EA PRS COMBINATION
# ============================================================

# ---- Autosomal EA PRS ----
EA_autosomes <- read_table(file.path(path, "PRS_EA_autosomes.profile")) %>%
  select(FID, IID, EA_PRS_autosomes = SCORESUM)

# ---- ChrX EA PRS ----
EA_chrX <- read_table(file.path(path, "PRS_EA_chrX.profile")) %>%
  select(FID, IID, EA_PRS_chrX = SCORESUM)

# ---- Combine EA PRS Components ----
EA_PRS_combined <- EA_autosomes %>%
  left_join(EA_chrX, by = c("FID", "IID")) %>%
  mutate(EA_PRS_total = EA_PRS_autosomes + EA_PRS_chrX)

# ---- Save EA PRS Raw Score ----
write_csv(EA_PRS_combined, file.path(path, "PRS_EA_combined.csv"))


# ============================================================
# 2. MA PRS COMBINATION
# ============================================================

# ---- Autosomal MA PRS ----
MA_autosomes <- read_table(file.path(path, "PRS_MA_autosomes.profile")) %>%
  select(FID, IID, MA_PRS_autosomes = SCORESUM)

# ---- ChrX MA PRS ----
MA_chrX <- read_table(file.path(path, "PRS_MA_chrX.profile")) %>%
  select(FID, IID, MA_PRS_chrX = SCORESUM)

# ---- Combine MA PRS Components ----
MA_PRS_combined <- MA_autosomes %>%
  left_join(MA_chrX, by = c("FID", "IID")) %>%
  mutate(MA_PRS_total = MA_PRS_autosomes + MA_PRS_chrX)

# ---- Save MA PRS Raw Score ----
write_csv(MA_PRS_combined, file.path(path, "PRS_MA_combined.csv"))
