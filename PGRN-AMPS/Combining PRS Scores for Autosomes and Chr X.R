##### Combining PRS Scores for Autosomes & Chr X, adding PCs #####

library(tidyverse)

path <- "/Users/knowak/Desktop/PRS Scores Final"

#### EA #####
EA_autosomes <- read_table(file.path(path, "PRS_EA_autosomes.profile")) %>%
  select(FID, IID, EA_PRS_autosomes = SCORESUM)

EA_chrX <- read_table(file.path(path, "PRS_EA_chrX.profile")) %>%
  select(FID, IID, EA_PRS_chrX = SCORESUM)

# Combine the two PRS into one dataframe
EA_PRS_combined <- EA_autosomes %>%
  left_join(EA_chrX, by = c("FID", "IID")) %>%
  mutate(EA_PRS_total = EA_PRS_autosomes + EA_PRS_chrX)

# Save the combined PRS
write_csv(EA_PRS_combined, file.path(path, "PRS_EA_combined.csv"))


#### MA #####
MA_autosomes <- read_table(file.path(path, "PRS_MA_autosomes.profile")) %>%
  select(FID, IID, MA_PRS_autosomes = SCORESUM)

MA_chrX <- read_table(file.path(path, "PRS_MA_chrX.profile")) %>%
  select(FID, IID, MA_PRS_chrX = SCORESUM)

# Combine the two PRS into one dataframe
MA_PRS_combined <- MA_autosomes %>%
  left_join(MA_chrX, by = c("FID", "IID")) %>%
  mutate(MA_PRS_total = MA_PRS_autosomes + MA_PRS_chrX)

# Save the combined PRS
write_csv(MA_PRS_combined, file.path(path, "PRS_MA_combined.csv"))
