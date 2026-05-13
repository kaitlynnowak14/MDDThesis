library(dplyr)

subset_pgrn <- master_final %>%
  transmute(
    cohort = "PGRN_AMPS",
    
    sex,
    age,
    ageonset,
    
    education_ord = highdegree,
    employment_ord = currentempstat,
    marital_ord = maritalstatus,
    
    ses_combined
  )

write.csv(subset_pgrn, "demographic_subset.csv", row.names = FALSE)
