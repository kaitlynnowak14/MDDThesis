"""
merge_phenotypes.py

Notes:
- This script merges the phenotype datasets from the All of Us Researcher Program (Controlled Tier v8) into a single dataset.
- The merge relies on the DataFrames created in the previous import steps.
- Variable names must match the ones used when importing.
- Includes person-level, survey, and condition occurrences data.
- Saves the merged dataset to the Google Cloud Storage bucket specificed by WORKSPACE_BUCKET.
"""

# ================
# Merge Phenotypes
# ================

##### Load DataFrames from Previous Queries #####
# These variables must match the dataset names created in the import steps
person_df = dataset_95202759_person_df
survey_df = dataset_95202759_survey_df
condition_df = dataset_95202759_condition_df
survey_df2 = dataset_44278276_survey_df

##### Process Old Survey Data #####
# Keep only the most recent answer per person/question
survey_recent = survey_df.drop_duplicates(subset=["person_id", "question"], keep="last")

# Remove prefixes from question names for clarity
survey_recent["question"] = survey_recent["question"].str.replace(r"^.*?:\s*", "", regex=True)

# Pivot table so each question becomes a column, concatenating multiple answers
survey_pivot = survey_recent.pivot_table(
    index="person_id",
    columns="question",
    values="answer",
    aggfunc=lambda x: "; ".join(x.astype(str).unique())
).reset_index()
survey_pivot.columns.name = None

##### Process New Survey Data #####
# Convert datetime column to pandas datetime
survey_df2["survey_datetime"] = pd.to_datetime(survey_df2["survey_datetime"], errors="coerce")

# Keep only the most recent survey per person
survey_recent2 = (
    survey_df2.sort_values("survey_datetime")
    .groupby("person_id", as_index=False)
    .last()  # keep most recent datetime
)

##### Merge Surveys with Person Data #####
# Merge person info with old and new survey datasets
person_survey_df = person_df.merge(survey_pivot, on="person_id", how="left")
person_survey_df = person_survey_df.merge(survey_recent2, on="person_id", how="left")

##### Process Condition Data #####
# Keep earliest condition occurrence per person
conditions_unique = (
    condition_df
    .sort_values("condition_start_datetime")
    .drop_duplicates("person_id")
    .loc[:, ["person_id", "condition_start_datetime"]]
)

##### Merge EAll Phenotype Data #####
merged_df = person_survey_df.merge(conditions_unique, on="person_id", how="left")

# Drop Sex at Birth column if present
if 'Sex At Birth' in merged_df.columns:
    merged_df = merged_df.drop(columns=['Sex At Birth'])

##### Save Merged Dataset to GCS #####
bucket = os.getenv("WORKSPACE_BUCKET")
if bucket is None:
    raise ValueError("WORKSPACE_BUCKET environment variable not found.")

gcs_path = f"{bucket}/exports/all_of_us_merged_dataset.csv"
merged_df.to_csv(gcs_path, index=False)
print(f"Saved merged dataset to {gcs_path}")

##### Quick Inspection #####
print(f"Number of participants: {len(merged_df)}")
display(merged_df.head(10))

# Check how many participants are missing conditon data
missing_conditions = merged_df['condition_start_datetime'].isnull().sum()
print(f"Participants missing condition data: {missing_conditions}")
