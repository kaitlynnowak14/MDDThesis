# Clean dbGaP Phenotype File #

# 0. Load libraries ####
library(readr)
library(dplyr)
library(tidyr)
library(XML)

# 1. Set base & save paths for files ####
base_path <- "/Users/knowak/Desktop/PGRN-AMPS/Files Needed for Analyses"
save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"

# 2. Load phenotype file ####
phenos <- read_tsv(
  gzfile(file.path(base_path, 
                   "phs000670.v1.pht003556.v1.p1.c1.PGRN_AMPS_Subject_Phenotypes.HMB.txt.gz")),
  skip = 10   
)
# 3. Filter participants (Remove excluded, those who put "Other" for lookup.race, & "U" for marital status #### 
phenos_filtered <- phenos %>%
  filter(IsExcluded == "No") %>%
  filter(lookup.race != "Other") %>%
  filter(maritalstatus != "U")

# 4. Remove unnecessary columns ####
columns_needed <- c("dbGaP_Subject_ID", "SUBJID", "lookup.race", "race", "gender", "age", "ageonset", "highdegree",
                    "currentempstat", "currentstudent", "maritalstatus", "EVEC.1", "EVEC.2", 
                    "EVEC.3", "EVEC.4")

phenos_clean <- phenos_filtered %>%
  select(all_of(columns_needed))

# 5. Remove participants with any missing data ####
phenos_clean <- phenos_clean %>%
  drop_na()  # removes any participant with NA in any of the selected columns

# 6. Save clean phenotype for analyses ####
write.csv(phenos_clean, file.path(save_path, "PGRN_AMPS_Phenotypes_Clean.csv"), row.names = FALSE)
