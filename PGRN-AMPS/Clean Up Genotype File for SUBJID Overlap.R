##### Clean Up Genotype File for SUBJID Overlap #####

# Load libraries
library(dplyr)
library(snpStats)
library(data.table)

# Set base & save paths for files
base_path <- "/Users/knowak/Desktop/PGRN-AMPS/Files Needed for Analyses"
save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"

# 1. Load phenotype files if not already done
phenos_clean <- read_csv(file.path(save_path, "PGRN_AMPS_Phenotypes_Clean.csv"))

# 2. # Extract the SUBJIDs from your cleaned phenotype table
participant_ids <- phenos_clean$SUBJID

# 3. Fix and save file
# Create a two-column keep file: FID and IID
keep_file <- data.frame(
  FID = phenos_clean$SUBJID,
  IID = phenos_clean$SUBJID
)

write.table(
  keep_file,
  file = "/Users/knowak/Desktop/PGRN-AMPS/Files Needed for Analyses/genotype_matrix/sub/sub20131107/SUBJIDs_to_keep.txt",
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE,
  sep = "\t"
)
