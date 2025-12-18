"""
Age_of_Onset.py

This script derives an Age of Onset (AoO) variable for Major Depressive Disorder (MDD)
using the merged All of Us phenotype dataset.

Notes:
- Age of onset is calculated as the floored age (in years) at first recorded condition onset.
- Dates are derived from date of birth and condition start datetime.
- The script generates descriptive statistics, distribution plots, normality tests,
candidate transformations, and sex-stratified summaries.
- This script depends on `merged_df` created in the phenotype merging step.
- Outputs are saved to the workspace bucket specified by WORKSPACE_BUCKET.
"""

# =====================
# Age of Onset Variable
# =====================

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import skew, kurtosis
import os

##### Environment Setup #####
# Ensure the Google Cloud Storage bucket environment variable is set.
# All output files will be saved to this bucket.
bucket = os.getenv("WORKSPACE_BUCKET")
if bucket is None:
    raise ValueError("WORKSPACE_BUCKET environment variable not found.")

##### Create Age of Onset Variable #####
# Convert relevant columns to datetime for calculation
merged_df['date_of_birth'] = pd.to_datetime(merged_df['date_of_birth'])
merged_df['condition_start_datetime'] = pd.to_datetime(merged_df['condition_start_datetime'])

# Record number of rows before dropping missing values
before_count = len(merged_df)

# Compute age of onset in years, floored to nearest integer
merged_df['age_of_onset'] = np.floor(
    (merged_df['condition_start_datetime'] - merged_df['date_of_birth']).dt.days / 365.25
).astype('Int64')

# Drop rows where age of onset is missing and record count after
merged_df = merged_df.dropna(subset=['age_of_onset'])
after_count = len(merged_df)
dropped_rows = before_count - after_count

print(f"Total rows before: {before_count}")
print(f"Total rows after: {after_count}")
print(f"Dropped rows (missing age_of_onset): {dropped_rows}")

##### Save Dataset #####
# Save the updated merged dataset with age of onset to GCS
csv_path = f"{bucket}/exports/merged_with_age_of_onset.csv"
merged_df.to_csv(csv_path, index=False)
print(f"Saved merged dataset with age_of_onset to: {csv_path}")

##### Quick Inspection #####
# Display the first 10 rows to confirm age of onset calculation
display(merged_df.head(10))

##### Plot Distribution #####
# Histogram of age of onset to visualize distribution
plt.figure(figsize=(10,6))
plt.hist(merged_df['age_of_onset'], bins=30, color='skyblue', edgecolor='black')
plt.xlabel('Age of Onset (years)')
plt.ylabel('Number of Individuals')
plt.title('Distribution of Age of Onset for MDD')
plt.show()  # show locally

# Save histogram to GCS
hist_path = f"{bucket}/plots/age_of_onset_hist.png"
plt.savefig("age_of_onset_hist.png")
os.system(f"gsutil cp age_of_onset_hist.png {hist_path}")
plt.close()
print(f"Saved histogram to: {hist_path}")

##### Descriptive Statistics #####
# Calculate mean, median, standard deviation, min, max, skewness, and kurtosis
age_onset_numeric = merged_df['age_of_onset'].astype(float)

summary_stats_df = pd.DataFrame({
    'Mean': [age_onset_numeric.mean()],
    'Median': [age_onset_numeric.median()],
    'Std': [age_onset_numeric.std()],
    'Min': [age_onset_numeric.min()],
    'Max': [age_onset_numeric.max()],
    'Skew': [skew(age_onset_numeric, nan_policy="omit")],
    'Kurtosis': [kurtosis(age_onset_numeric, nan_policy="omit")]
})

# Save descriptive stats to GCS
summary_stats_path = f"{bucket}/exports/age_of_onset_summary.csv"
summary_stats_df.to_csv(summary_stats_path, index=False)
print(f"Saved summary stats to: {summary_stats_path}")

# Display summary stats in notebook
display(summary_stats_df)

##### Q–Q plot #####
# Generate Q-Q plot to assess normality
import statsmodels.api as sm
import matplotlib.pyplot as plt
sm.qqplot(age_onset_numeric, line='45', fit=True)
plt.title("Q–Q Plot of Age of Onset")
plt.show()

# Save Q-Q plot to GCS
qqplot_path = f"{bucket}/plots/aoo_qqplot.png"
plt.savefig("aoo_qqplot.png")
os.system(f"gsutil cp aoo_qqplot.png {qqplot_path}")
plt.close()
print(f"Saved Q–Q plot to: {qqplot_path}")

##### Candidate transformations #####
# Load libraries if needed
import seaborn as sns
from scipy.stats import boxcox, yeojohnson

# Prepare AoO data for transformation by dropping NAs
aoo = merged_df['age_of_onset'].dropna()

# Ensure positive floats for Box-Cox
aoo = merged_df['age_of_onset'].dropna().astype(float).to_numpy()

# Apply common transformations and visualize distributions
transformations = {
    "Original": aoo,
    "Log": np.log1p(aoo),
    "Sqrt": np.sqrt(aoo),
    "Square": np.square(aoo),
    "Reciprocal": 1 / (aoo + 1),
    "Box-Cox": boxcox(aoo + 1)[0],
    "Yeo-Johnson": yeojohnson(aoo)[0]
}

# Plot histograms of transformations
fig, axes = plt.subplots(3, 3, figsize=(15,12))
axes = axes.flatten()

for i, (name, data) in enumerate(transformations.items()):
    sns.histplot(data, bins=30, kde=True, ax=axes[i], color="skyblue")
    axes[i].set_title(name)

plt.tight_layout()
plt.show()

##### Tests for Normality #####
# Import needed libraries
from scipy.stats import shapiro, normaltest, anderson

# Use your age of onset data
aoo = merged_df['age_of_onset'].dropna().astype(float).to_numpy()

# D’Agostino & Pearson’s normality test
dagostino_stat, dagostino_p = normaltest(aoo)
print("D’Agostino & Pearson Test:")
print(f"Statistic={dagostino_stat:.4f}, p={dagostino_p:.4e}")

# Anderson–Darling test for normality
anderson_result = anderson(aoo)
print("\nAnderson–Darling Test:")
print(f"Statistic={anderson_result.statistic:.4f}")
print("Critical values:", anderson_result.critical_values)
print("Significance levels:", anderson_result.significance_level)

##### Stratification by Sex #####
# Import needed libraries
import seaborn as sns
from scipy.stats import boxcox, yeojohnson

# Create sex groups split by sex at birth (Male & Female)
sex_groups = merged_df['sex_at_birth'].unique()  # e.g., ['Male', 'Female']
results = []

# Subset AoO for sex
for sex in sex_groups:
    # Subset data for this sex
    aoo_sex = merged_df.loc[merged_df['sex_at_birth'] == sex, 'age_of_onset'].dropna().astype(float).to_numpy()

    # Histogram plot
    plt.figure(figsize=(10,6))
    plt.hist(aoo_sex, bins=30, color='skyblue', edgecolor='black')
    plt.xlabel('Age of Onset (years)')
    plt.ylabel('Number of Individuals')
    plt.title(f'Distribution of Age of Onset for {sex}')
    plt.show()
    
    # QQ plot
    sm.qqplot(aoo_sex, line='45', fit=True)
    plt.title(f"QQ Plot of Age of Onset ({sex}, Original)")
    plt.show()
    
    # Summary Statistics
    stats = {
    'Sex': sex,
    'Mean': np.mean(aoo_sex),
    'Median': np.median(aoo_sex),
    'Std': np.std(aoo_sex, ddof=1),  # sample standard deviation
    'Min': np.min(aoo_sex),
    'Max': np.max(aoo_sex),
    'Skew': skew(aoo_sex, nan_policy='omit'),
    'Kurtosis': kurtosis(aoo_sex, nan_policy='omit')
}
    
    results.append(stats)

    # Apply candidate transformations for visualization
    transformations = {
        "Original": aoo_sex,
        "Log": np.log1p(aoo_sex),
        "Sqrt": np.sqrt(aoo_sex),
        "Square": np.square(aoo_sex),
        "Reciprocal": 1 / (aoo_sex + 1),      # avoid div by 0
        "Box-Cox": boxcox(aoo_sex + 1)[0],    # strictly > 0
        "Yeo-Johnson": yeojohnson(aoo_sex)[0]
    }
    
    # Plot histograms
    fig, axes = plt.subplots(3, 3, figsize=(15,12))
    axes = axes.flatten()
    
    for i, (name, data) in enumerate(transformations.items()):
        sns.histplot(data, bins=30, kde=True, ax=axes[i], color="skyblue")
        axes[i].set_title(f"{name} ({sex})")
    
    # Hide unused subplots
    for j in range(i+1, len(axes)):
        axes[j].set_visible(False)
    
    plt.tight_layout()
    plt.show()

##### Combine Results #####
# Compile sex-stratifies summary statistics into a single DataFrame
summary_df = pd.DataFrame(results)
display(summary_df)
