# =====================================================
# 3. Restrict Final Datasets to Those Identify as EUR Through PCA
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
