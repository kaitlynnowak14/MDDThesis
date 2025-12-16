"""
Sociodemographic_Characteristics.py

This script generates a Table 1-style summary of sociodemographic characteristics for the merged All of Us phenotype dataset.

Notes:
- Categories are collapsed for reporting purposes.
- Output is saved as a CSV to the workspace bucket.
- This script depends on `merged_df` created in the phenotype merging step.
"""
# ================================
# Sociodemographic Characteristics
# ================================

import pandas as pd
import os

##### Define Variables and Collapsed Categories #####
# Categories below define how raw survey responses are grouped for Table 1 Display.
# Each sub-list represents a single row.
categories = {
    "Sex at Birth": [
        ["Female"],
        ["Male"]
    ],
    "Marital status": [
        ["Never Married"],
        ["Separated", "Divorced", "Widowed"],  # collapsed row
        ["Living With Partner", "Married"]     # collapsed row
    ],
    "Highest educational level": [
        ["Never Attended", "One Through Four", "Five Through Eight", "Nine Through Eleven"],  # collapsed row
        ["Twelve Or GED"],
        ["College One to Three"],
        ["College Graduate"],
        ["Advanced Degree"]
    ],
    "Employment Status": [
        ["Unable To Work"],
        ["Out Of Work One Or More", "Out Of Work Less Than One"],  # collapsed row
        ["Homemaker", "Student"],                                 # collapsed row
        ["Employed For Wages", "Self Employed"],                  # collapsed row
        ["Retired"]
    ]
}

##### Function: Build Table 1 #####
def make_table(df, categories):
  """
  Creates a Table 1-style summary with counts and percentages
  for predefined sociodemographic categories.
  """
    results = []
    total = len(df)

    for var, groups in categories.items():
      # Add section header row
        results.append({"Characteristic": var, "n": "", "%": ""})
      
        for group in groups:
            n = df[var].isin(group).sum()
            pct = round((n / total) * 100, 1) if total > 0 else 0
            label = "   " + "/".join(group)
            results.append({"Characteristic": label, "n": n, "%": pct})
    
    return pd.DataFrame(results)

##### Clean Survey Column Labels #####
# Remove question prefixes from survey responses
for col in ["Current Marital Status", "Highest Grade", "Employment Status"]:
    if col in merged_df.columns:
        merged_df[col] = merged_df[col].str.replace(r"^.*?:\s*", "", regex=True)

##### Rename Columns for Display #####
# Align column names with category dictionary
renamed_df = merged_df.rename(columns={
    "sex_at_birth": "Sex at Birth",
    "Current Marital Status": "Marital status",
    "Highest Grade": "Highest educational level",
    "Employment Status": "Employment Status"
})

##### Generate Table 1 #####
table1 = make_table(renamed_df, categories)

##### Format Counts #####
# Add commas to participant counts for readability
table1["n"] = table1["n"].apply(lambda x: f"{x:,}" if isinstance(x, int) else x)

##### Save Table to Workspace Bucket #####
bucket = os.getenv("WORKSPACE_BUCKET")
if bucket is None:
    raise ValueError("WORKSPACE_BUCKET environment variable not found. Must run inside a Terra/All of Us notebook.")

gcs_path = f"{bucket}/results/table1_characteristics.csv"
table1.to_csv(gcs_path, index=False)
print(f"Saved Table 1 to {gcs_path}")

##### Display Output #####
display(table1)
