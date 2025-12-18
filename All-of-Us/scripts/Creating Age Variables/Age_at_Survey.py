"""
Age_at_Survey.py

This script calculates the Age at Survey variable for participants in the merged All of Us phenotype dataset.

Notes:
- Age at survey is calculated as the floored number of year between date of birth and survey datetime.
- Generates descriptive statistics and a histogram.
- Outputs are saved to the workspace bucket specficied by WORKSAPCE_BUCKET.
- This script depends on `merged_df` created in the phenotype merging step.
"""

# =============
# Age at Survey
# =============

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

##### Ensure datetime types #####
# Convert birthdate and survey datetime columns to pandas datetime
merged_df['date_of_birth'] = pd.to_datetime(merged_df['date_of_birth'], errors='coerce')
merged_df['survey_datetime'] = pd.to_datetime(merged_df['survey_datetime'], errors='coerce')

##### Compute Age at Survey #####
# Calculate age in whole years (floored) and store in new column
merged_df['age_at_survey'] = ((merged_df['survey_datetime'] - merged_df['date_of_birth']).dt.days // 365).astype('Int64')

##### Plot Distribution #####
# Histogram to visualize distribution of age at survey
plt.figure(figsize=(8,5))
plt.hist(merged_df['age_at_survey'].dropna(), bins=30, color='skyblue', edgecolor='black')
plt.title("Distribution of Age at Survey")
plt.xlabel("Age (years)")
plt.ylabel("Count")
plt.grid(axis='y', alpha=0.75)
plt.show()

##### Summary Statistics #####
# Calculate descriptive statistics including skewness and kurtosis
age_stats = merged_df['age_at_survey'].describe().to_frame().transpose()
age_stats['skew'] = merged_df['age_at_survey'].skew()
age_stats['kurtosis'] = merged_df['age_at_survey'].kurtosis()

print("Summary statistics for age_at_survey:")
display(age_stats)

##### Save Outputs #####
# Ensure workspce bucket is available
bucket = os.getenv("WORKSPACE_BUCKET")
if bucket is None:
    raise ValueError("WORKSPACE_BUCKET environment variable not found.")

# Save age at survey CSV
age_stats_file = "summary_age_at_survey.csv"
merged_df[['person_id', 'age_at_survey']].to_csv(age_stats_file, index=False)
os.system(f"gsutil cp {age_stats_file} {bucket}/{age_stats_file}")

# Save histogram figure
fig_file = "age_at_survey_histogram.png"
plt.figure(figsize=(8,5))
plt.hist(merged_df['age_at_survey'].dropna(), bins=30, color='skyblue', edgecolor='black')
plt.title("Distribution of Age at Survey")
plt.xlabel("Age (years)")
plt.ylabel("Count")
plt.grid(axis='y', alpha=0.75)
plt.savefig(fig_file)
os.system(f"gsutil cp {fig_file} {bucket}/{fig_file}")

print(f"Saved summary stats to {bucket}/{age_stats_file}")
print(f"Saved histogram to {bucket}/{fig_file}")
