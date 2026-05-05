# ============================================================
# Title: EUR Ancestry Filtering Script
# Dataset: All of Us (European Ancestry subset)
#
# Description:
#   - Loads European ancestry subject IDs from Hail table
#   - Filters phenotype dataframe to retain EUR-only samples
#   - Ensures ID type consistency between Hail and pandas
#
# Inputs:
#   - eur_subject_ids.ht (Hail Table)
#   - merged_df (pandas DataFrame; must exist in memory or be loaded)
#
# Output:
#   - Filtered merged_df (EUR-only cohort)
# =============================================================

# =====================================================
# 1. Restrict Final Datasets to Those Identify as EUR Through PCA
# =====================================================

# Load Hail table containing European subject IDs
eur_ht = hl.read_table("eur_subject_ids.ht")

# make sure 's' is the key field containing IDs
print(eur_ht.describe())

# Convert merged_df IDs to string to match Hail table
merged_df['person_id'] = merged_df['person_id'].astype(str)

# Collect Hail table IDs
eur_ids = set(map(str, eur_ht.s.collect()))

# Filter merged_df to only those who have matching IDs in European ID list
merged_df = merged_df[merged_df['person_id'].isin(eur_ids)].copy()

# Confirm final number of participants
print("Number of participants after EUR/genomic QC filter:", merged_df.shape[0])
