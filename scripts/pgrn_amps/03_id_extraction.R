# ============================================================
# Title: Subset ID Extraction for Genotype Matching (PGRN-AMPS Cohort)
# Dataset: Cleaned dbGaP Phenotypes
#
# Description:
#   - Extracts SUBJIDs for genotype QC pipeline
#   - Creates PLINK-compatible keep file (FID/IID)
#   - Used for genotype filtering and downstream PRS analysis
#
# Output:
#   SUBJIDs_to_keep.txt
# =============================================================

# =====================================================
# 1. LOAD LIBRARIES & DATA
# =====================================================

ibrary(dplyr)
library(snpStats)
library(data.table)

# Set base & save paths for files
base_path <- "/Users/knowak/Desktop/PGRN-AMPS/Files Needed for Analyses"
save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"

phenos_clean <- read_csv(file.path(save_path, "PGRN_AMPS_Phenotypes_Clean.csv"))

# =====================================================
# 2. EXTRACT PARTICIPANT IDS
# =====================================================

participant_ids <- phenos_clean$SUBJID

# 3. Fix and save file
# Create a two-column keep file: FID and IID
keep_file <- data.frame(
  FID = phenos_clean$SUBJID,
  IID = phenos_clean$SUBJID
)

# =====================================================
# 3. WRITE PLINK KEEP FILE
# =====================================================

write.table(
  keep_file,
  file = "/Users/knowak/Desktop/PGRN-AMPS/Files Needed for Analyses/genotype_matrix/sub/sub20131107/SUBJIDs_to_keep.txt",
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE,
  sep = "\t"
)
