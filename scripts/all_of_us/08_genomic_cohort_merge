# ============================================================
# Title: Genomic PRS Integration and Cohort Merging Pipeline
# Dataset: All of Us Controlled Tier + PRS Outputs + PCs
#
# Description:
#   - Load EA and MA PRS results
#   - Merge with phenotype and genetic PCs
#   - Standardize PRS scores
#   - Generate final analysis-ready dataset
#   - Produce PRS distribution visualization
#
# Output:
#   - final_merged_dataset.csv
#   - EA_MA_PRS_density_plot.png
#
# Notes:
#   - No filtering or QC changes applied in this script
#   - Pure integration + standardization + visualization pipeline
# ============================================================

# =====================================================
# 1. SET UP
# =====================================================

# ---- Import & Initialize Hail ----
import hail as hl
hl.init()

# ---- Import Libraries ----
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler

# ---- Confirm files names ----
!gsutil ls gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/

# =====================================================
# 2. Import EA, MA, PCs, and Phenotype Tables 
# =====================================================

!gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/EA_PRS_results.profile .
!gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MA_PRS_results.profile .
!gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/all_of_us_final_dataset.csv .
!gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/cohort_PCs.csv .

# ---- Set Up Simple Naming Structure ----
ea = pd.read_csv("EA_PRS_results.profile", delim_whitespace=True)
ma = pd.read_csv("MA_PRS_results.profile", delim_whitespace=True)

pcs = pd.read_csv("cohort_PCs.csv")

pheno = pd.read_csv("all_of_us_final_dataset.csv")

# ---- Check Structure of Files ----
print(ea.columns)
print(ma.columns)
print(pcs.columns)
print(pheno.columns)

# =====================================================
# 3. Standardize Column Naming Across Files
# =====================================================

ea = ea.rename(columns={"SCORESUM": "EA_PRS"})
ma = ma.rename(columns={"SCORESUM": "MA_PRS"})

pcs = pcs.rename(columns={"research_id": "person_id"})

ea["person_id"] = ea["IID"]
ma["person_id"] = ma["IID"]

# Quick Inspection
print(ea["person_id"].head())
print(pheno["person_id"].head())
print(pcs["person_id"].head())

# =====================================================
# 4. Merge Datasets
# =====================================================
# Merge EA PRS
merged = pheno.merge(
    ea[["person_id", "EA_PRS"]],
    on="person_id",
    how="left"
)

# Merge MA PRS
merged = merged.merge(
    ma[["person_id", "MA_PRS"]],
    on="person_id",
    how="left"
)

# Select all PC columns (pc_1 through pc_16)
pc_cols = [col for col in pcs.columns if col.startswith("pc_")]

# Merge all PCs
merged = merged.merge(
    pcs[["person_id"] + pc_cols],
    on="person_id",
    how="left"
)

# Inspect
print(merged.shape)
print(merged.columns)

# =====================================================
# 5. Create z-scored PRS Variables 
# =====================================================
scaler = StandardScaler()

merged[["EA_PRS_z","MA_PRS_z"]] = scaler.fit_transform(
    merged[["EA_PRS","MA_PRS"]]
)

# Inspect column names
print(merged.columns)

# =====================================================
# 6. Save Final Merged Table
# =====================================================
merged.to_csv("final_merged_dataset.csv", index=False)

merged.to_csv(
    "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/final_merged_dataset.csv",
    index=False
)
