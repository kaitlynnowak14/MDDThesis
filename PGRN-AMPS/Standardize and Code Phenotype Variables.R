##### Standardize and Code Phenotype Variables in EA Master File #####

# 0. Load libraries & set paths ####
library(dplyr)

save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"


# 1. Load files if not already done ####
# Make copy of master_EA_clean just incase
master_EA_clean_copy <- master_EA_clean


# 2. Recoding gender ####
master_EA_clean$gender <- ifelse(master_EA_clean$gender == "M", 0,
                                         ifelse(master_EA_clean$gender == "F", 1, NA))


# 3. Recoding maritalstatus ####
master_EA_clean$maritalstatus <- ifelse(master_EA_clean$maritalstatus %in% c("S"), 0,
                                          ifelse(master_EA_clean$maritalstatus %in% c("D","W","X"), 1,
                                                 ifelse(master_EA_clean$maritalstatus %in% c("M","C","P"), 2, NA)))
  

# 4. Recoding highdegree ####
master_EA_clean$highdegree <- ifelse(master_EA_clean$highdegree == 1, 0,
                                            ifelse(master_EA_clean$highdegree %in% c(2,3), 1,
                                                   ifelse(master_EA_clean$highdegree %in% c(4,5), 2,
                                                          ifelse(master_EA_clean$highdegree == 6, 3,
                                                                 ifelse(master_EA_clean$highdegree %in% c(7,8), 4, NA)))))


# 5. Recoding currentempstat ####
master_EA_clean$currentempstat <- ifelse(master_EA_clean$currentempstat %in% c(3,4,5), 2,   # Employed
                                  ifelse(master_EA_clean$currentempstat == 2, 1,      # Unemployed looking
                                         0))     # Out of workforce (retired, unemployed not looking)


# 6. Remove current student ####
master_EA_clean$currentstudent <- NULL


# 7. Make combined SES column and standarize it
## 7.1 Scale and standardize each SES variable
# Min–max scaling function
min_max <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}

# Standardize each SES component
master_EA_clean$marital_ses_std <- min_max(master_EA_clean$maritalstatus)
master_EA_clean$education_ses_std <- min_max(master_EA_clean$highdegree)
master_EA_clean$employment_ses_std <- min_max(master_EA_clean$currentempstat)

## 7.2 Combine and equally weight
# Raw SES sum
master_EA_clean$ses_combined_raw <-
  master_EA_clean$marital_ses_std +
  master_EA_clean$education_ses_std +
  master_EA_clean$employment_ses_std

# Final SES index scaled 0–1
master_EA_clean$ses_combined <- min_max(master_EA_clean$ses_combined_raw)


# 8. Save as CSV ####
write.csv(master_EA_clean, file = file.path(save_path, "master_EA_final.csv"),
          row.names = FALSE)
# ==============================================================================
##### Standardize and Code Phenotype Variables in MA Master File #####

save_path <- "/Users/knowak/Desktop/PGRN-AMPS/New Files"


# 1. Load files if not already done ####
master_MA_clean <- read.csv(file.path(save_path, "master_MA.csv"))

# Make copy of master_MA_clean just incase
master_MA_clean_copy <- master_MA_clean


# 2. Recoding gender ####
master_MA_clean$gender <- ifelse(master_MA_clean$gender == "M", 0,
                                 ifelse(master_MA_clean$gender == "F", 1, NA))


# 3. Recoding maritalstatus ####
master_MA_clean$maritalstatus <- ifelse(master_MA_clean$maritalstatus %in% c("S"), 0,
                                        ifelse(master_MA_clean$maritalstatus %in% c("D","W","X"), 1,
                                               ifelse(master_MA_clean$maritalstatus %in% c("M","C","P"), 2, NA)))


# 4. Recoding highdegree ####
master_MA_clean$highdegree <- ifelse(master_MA_clean$highdegree == 1, 0,
                                     ifelse(master_MA_clean$highdegree %in% c(2,3), 1,
                                            ifelse(master_MA_clean$highdegree %in% c(4,5), 2,
                                                   ifelse(master_MA_clean$highdegree == 6, 3,
                                                          ifelse(master_MA_clean$highdegree %in% c(7,8), 4, NA)))))


# 5. Recoding currentempstat ####
master_MA_clean$currentempstat <- ifelse(master_MA_clean$currentempstat %in% c(3,4,5), 2,   # Employed
                                         ifelse(master_MA_clean$currentempstat == 2, 1,      # Unemployed looking
                                                0))     # Out of workforce (retired, unemployed not looking)


# 6. Remove current student ####
master_MA_clean$currentstudent <- NULL


# 7. Make combined SES column and standarize it
## 7.1 Scale and standardize each SES variable
# Min–max scaling function
min_max <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}

# Standardize each SES component
master_MA_clean$marital_ses_std <- min_max(master_MA_clean$maritalstatus)
master_MA_clean$education_ses_std <- min_max(master_MA_clean$highdegree)
master_MA_clean$employment_ses_std <- min_max(master_MA_clean$currentempstat)

## 7.2 Combine and equally weight
# Raw SES sum
master_MA_clean$ses_combined_raw <-
  master_MA_clean$marital_ses_std +
  master_MA_clean$education_ses_std +
  master_MA_clean$employment_ses_std

# Final SES index scaled 0–1
master_MA_clean$ses_combined <- min_max(master_MA_clean$ses_combined_raw)


# 8. Save as CSV ####
write.csv(master_MA_clean, file = file.path(save_path, "master_MA_final.csv"),
          row.names = FALSE)
# ==============================================================================

# 9. Create a demographics table and save
if (!require(tableone)) install.packages("tableone")
library(tableone)

## 9.1 Total N
total_N <- nrow(master_EA_clean)

## 9.2 Helper function
freq_pct <- function(x, labels, total_N) {
  tab <- table(x)
  pct <- (tab / total_N) * 100
  data.frame(
    Level = labels,
    Frequency = as.numeric(tab),
    Percent = round(as.numeric(pct), 1),
    stringsAsFactors = FALSE
  )
}

## 9.3 Build each variable
### 9.3.1 Gender
gender_levels <- c("Male", "Female")

gender_tbl <- freq_pct(master_EA_clean$gender,
                       gender_levels,
                       total_N)

gender_tbl <- rbind(
  data.frame(Level = "Gender", Frequency = "", Percent = ""),
  gender_tbl
)

### 9.3.2 Marital Status
marital_levels <- c("Single",
                    "Divorced/Widowed/Separated",
                    "Married/Cohabitating/Life Partner")

marital_tbl <- freq_pct(master_EA_clean$maritalstatus,
                        marital_levels,
                        total_N)

marital_tbl <- rbind(
  data.frame(Level = "Marital Status", Frequency = "", Percent = ""),
  marital_tbl
)

### 9.3.3 Education
education_levels <- c("None",
                      "GED/High School",
                      "Some College/Associate/Technical",
                      "College Degree",
                      "Masters/Professional")

education_tbl <- freq_pct(master_EA_clean$highdegree,
                          education_levels,
                          total_N)

education_tbl <- rbind(
  data.frame(Level = "Education", Frequency = "", Percent = ""),
  education_tbl
)

# 9.3.4 Employment
employment_levels <- c("Not in Workforce",
                       "Unemployed Looking",
                       "Employed")

employment_tbl <- freq_pct(master_EA_clean$currentempstat,
                           employment_levels,
                           total_N)

employment_tbl <- rbind(
  data.frame(Level = "Employment Status", Frequency = "", Percent = ""),
  employment_tbl
)

## 9.4 Combine into 1 table
demographics_table <- rbind(
  gender_tbl,
  marital_tbl,
  education_tbl,
  employment_tbl
)

demographics_table

## 9.5 Save table
write.csv(demographics_table,file = file.path(save_path, "Table1_Demographics.csv"),
          row.names = FALSE)

# 10. Mean Age of Onset
mean(master_EA_clean$ageonset, na.rm = TRUE)

# ==============================================================================
##### Combine EA and MA final tables #####
master_MA_final <- read.csv(file.path(save_path, "master_MA_final.csv"))

master_final <- master_EA_final

# Add MA PRS columns
master_final$MA_PRS_total <- master_MA_final$MA_PRS_total
master_final$MA_PRS_z <- master_MA_final$MA_PRS_z

# Reorder PRS columns so they are adjacent
master_final <- master_final[, c(
  "SUBJID", "FID", "IID",
  "EA_PRS_total", "EA_PRS_z",
  "MA_PRS_total", "MA_PRS_z",
  setdiff(names(master_final),
          c("SUBJID", "FID", "IID",
            "EA_PRS_total", "EA_PRS_z",
            "MA_PRS_total", "MA_PRS_z"))
)]

# Save final
write.csv(master_final,file = file.path(save_path, "Master_Final.csv"),
          row.names = FALSE)
