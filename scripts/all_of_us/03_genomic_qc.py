# ============================================================
# Title: All of Us Genomic Data QC Pipeline
# Dataset: All of Us (European Ancestry subset)
#
# Description:
#   - Load genotype data from All of Us WGS ACAF callset
#   - Perform sample-level QC (related + flagged individuals)
#   - Subset to predefined MDD thesis cohort
#   - Annotate ancestry using All of Us PCA-based predictions
#   - Restrict analysis to European ancestry samples
#   - Extract and save genetic PCs for downstream analysis
#   - Load and harmonize PRS weights (EA + MA)
#   - Perform liftover (GRCh37 → GRCh38)
#   - Split PRS weights and genotype data by chromosome
#
# Output:
#   - EUR subject IDs (Hail Table)
#   - Cohort PCs (CSV)
#   - Lifted PRS weights (GRCh38, chromosome-level Hail Tables)
#   - Chromosome-split genotype matrices (optional downstream PRS input)
#
# Notes: 
#   - Cohort is predefined using All of Us Cohort Builder
#   - All data are controlled-access and cannot be shared
#   - Pipeline is designed for reproducibility within Terra environment
#   - Weights files comes from Trans-ancestry GWAS (Adams et al., 2025)
# =============================================================

# =====================================================
# 1. Set Up Libraries and Environmental Paths
# =====================================================

# ---- Load Libraries ----
import os
import hail as hl
hl.init(default_reference='GRCh38', idempotent=True)

from bokeh.io import show, output_notebook
from bokeh.layouts import gridplot
output_notebook()

import pandas as pd
import ast
import seaborn as sns
import os

# ---- Environmental Paths ----
cdr_storage_path = os.environ.get("CDR_STORAGE_PATH")
acaf_split_mt_path = os.getenv("WGS_ACAF_THRESHOLD_SPLIT_HAIL_PATH")
auxiliary_path = "gs://fc-aou-datasets-controlled/v8/wgs/short_read/snpindel/aux"
sample_qc_path = f'{auxiliary_path}/qc'
workspace_bucket = os.environ['WORKSPACE_BUCKET']

# =====================================================
# 2. Load ACAF Threshold Callset
# =====================================================
acaf_split_mt = hl.read_matrix_table(acaf_split_mt_path)

# =====================================================
# 3. Remove Related and Flagged Samples (Code from All of Us)
# This is done on entire All of Us dataset to begin, before selecting for desired cohort
# =====================================================

# ---- Related Samples ----
relatedness = f'{auxiliary_path}/relatedness'
related_samples_path = f'{relatedness}/relatedness_flagged_samples.tsv'
related_remove = hl.import_table(related_samples_path,
                                 types={"sample_id":"tstr"},
                                key="sample_id")

acaf_split_mt = acaf_split_mt.anti_join_cols(related_remove)

# Count how many were removed
related_remove.count()

# ---- Flagged Samples ----
flagged_samples_path = f'{sample_qc_path}/flagged_samples.tsv'
flagged_samples = hl.import_table(flagged_samples_path, key='s')

acaf_split_mt = acaf_split_mt.anti_join_cols(flagged_samples)

# Count how many were removed
flagged_samples.count()

# =====================================================
# 4. Subset MT to Eur Cohort
# =====================================================

# Set path to cohort
mdd_cohort_path = "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/data/mdd_thesis_cohort.tsv"

# Import as Hail table
mdd_cohort_ht = hl.import_table(
    mdd_cohort_path,
    types={'person_id': hl.tstr},
    key='person_id'
)

# Subset MT directly to cohort using person_id
SNP_data_mt = acaf_split_mt.semi_join_cols(mdd_cohort_ht)

# SNP and participant count
SNP_data_mt.count()

# =====================================================
# 5. Ancestry Predictions Using All of Us Provided ancestry_preds
# =====================================================

# ---- Call Files and Annotate ----
ancestry_pred_path = f'{auxiliary_path}/ancestry/ancestry_preds.tsv'
ancestry_pred = hl.import_table(ancestry_pred_path, key='research_id', impute=True, types={"research_id":"tstr","pca_features":hl.tarray(hl.tfloat)})

# Annotate
SNP_data_mt = SNP_data_mt.annotate_cols(
    ancestry_pred = ancestry_pred[SNP_data_mt.s].ancestry_pred
)

# ---- Restrict to Eur only samples ----
SNP_data_mt = SNP_data_mt.filter_cols(
    SNP_data_mt.ancestry_pred == "eur"
)

# Convert to pandas after filtering
samples_eur_pd = SNP_data_mt.cols().to_pandas()

# See counts by ancestry to confirm all Eur
samples_eur_pd.groupby("ancestry_pred")["ancestry_pred"].count()

# Save subject IDs for filtering phenotype file
eur_subjects_ht = SNP_data_mt.cols().select()

eur_subjects_ht.write(
    "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/eur_subject_ids.ht",
    overwrite=True
)

# ---- Extract PCs and Save ----
# Convert Hail Table of ancestry predictions to pandas
cohort_ht = ancestry_pred.semi_join(SNP_data_mt.cols())
cohort_pd = cohort_ht.to_pandas()

# Convert PCS features to separate columns
pc_cols = [f'pc_{i}' for i in range(1, 17)]
cohort_pd[pc_cols] = pd.DataFrame(
    cohort_pd.pca_features.tolist(),
    index=cohort_pd.index
)

# Drop the original array column
cohort_pd = cohort_pd.drop(columns=['pca_features'])

# Save to CSV
pcs_csv_path = f"{workspace_bucket}/cohort_PCs.csv"
cohort_pd.to_csv(pcs_csv_path, index=False)

print(f"PCs saved to {pcs_csv_path}")

# Make sure PCA scatterplot looks reasonable
sns.scatterplot(
    data=cohort_pd,
    x='pc_1',
    y='pc_2',
    hue='ancestry_pred',
    alpha=0.05
)

# =====================================================
# 6. Load and Liftover PRS Weights Files (both EA and MA)
# =====================================================

# ---- Load Weights Files from Local Computer Into Cloud Environment ----
!gsutil cp /home/jupyter/workspaces/mddageofonset/TopEA_SNPs_GRCh37_weights.txt \
           gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/data/

!gsutil cp /home/jupyter/workspaces/mddageofonset/TopMA_SNPs_GRCh37_weights.txt \
           gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/data/

# ---- Prepare Weights Files for Liftover ----
weights_files = [
    "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/data/TopEA_SNPs_GRCh37_weights.txt",
    "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/data/TopMA_SNPs_GRCh37_weights.txt"
]

def load_weights_grch37(path):
    weights = hl.import_table(
        path,
        delimiter="\t",
        impute=True,
        no_header=False
    )

    # Strip quotes from column names (just in case)
    weights = weights.rename({k: k.replace('"','') for k in weights.row})

    # Rename to standard names
    weights = weights.rename({
        "SNP": "id",
        "A1": "a1",
        "A2": "a2",
        "BETA": "weight",
        "CHR": "chr",
        "BP": "pos"
    })

    # Clean chromosome + alleles
    weights = weights.annotate(
        chr = hl.str(weights.chr).replace("chr", ""),
        pos = hl.int(weights.pos),
        a1 = weights.a1.upper(),
        a2 = weights.a2.upper()
    )
    
    # Convert contig 23 → X for GRCh37
    weights = weights.annotate(
        chr = hl.if_else(weights.chr == '23', 'X', weights.chr)
    )

    # Build GRCh37 locus + alleles
    weights = weights.annotate(
        locus = hl.locus(weights.chr, weights.pos, reference_genome="GRCh37"),
        alleles = [weights.a1, weights.a2]
    )

    return weights.key_by("locus", "alleles")

# Create weights tables
weights_37 = [load_weights_grch37(p) for p in weights_files]

# ---- Liftover GRCh37 Chr and Pos to GRCh38 ----
# References
rg37 = hl.get_reference("GRCh37")
rg38 = hl.get_reference("GRCh38")

rg37.add_liftover(
    "gs://hail-common/references/grch37_to_grch38.over.chain.gz",
    rg38
)

def liftover_weights_to_grch38(weights):
    # 1. Unkey first
    weights = weights.key_by()

    # 2. Liftover locus
    weights = weights.annotate(
        locus_38 = hl.liftover(weights.locus, rg38)
    )

    # 3. Keep only successfully lifted variants
    weights = weights.filter(hl.is_defined(weights.locus_38))

    # 4. Replace locus
    weights = weights.annotate(
        locus = weights.locus_38
    ).drop("locus_38")

    # 5. Re-key by GRCh38 locus
    return weights.key_by("locus", "alleles")


# Apply liftover
weights_38 = [liftover_weights_to_grch38(w) for w in weights_37]

# =====================================================
# 7. Split Weights Tables by Chromosome
# =====================================================

# ---- European-ancestry ----
# Confirm weights file count
topEA_weights = weights_38[0]
print(f"Total SNPs in topEA_weights: {topEA_weights.count()}")

# unkey & rekey by locus only, not locus and allele
topEA_weights = (
    topEA_weights
        .key_by()          # drop (locus, alleles)
        .key_by("locus")   # rekey ONLY on locus
)

# See what chr column looks like
topEA_weights.aggregate(hl.agg.collect_as_set(topEA_weights.locus.contig))

# Subset weights file by chromosome
chromosomes = [f"chr{i}" for i in range(1, 23)] + ["chrX"]
weights_by_chr = {}

for chr_ in chromosomes:
    weights_by_chr[chr_] = topEA_weights.filter(topEA_weights.locus.contig == chr_)
    print(f"Chromosome {chr_}: {weights_by_chr[chr_].count()} SNPs")

# Save to bucket for downstream analysis
for chr_ in chromosomes:
    out = f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/weights_chr{chr_}.ht'

    weights_by_chr[chr_].write(out, overwrite=True)

    print(f"Wrote weights for {chr_}")

# ---- Multi-ancestry ----
# Confirm weights file count
topMA_weights = weights_38[1]
print(f"Total SNPs in topMA_weights: {topMA_weights.count()}")

# See what chr column looks like
topMA_weights.aggregate(hl.agg.collect_as_set(topMA_weights.locus.contig))

# Subset weights file by chromosome
chromosomes = [f"chr{i}" for i in range(1, 23)] + ["chrX"]
weights_by_chr_MA = {}

for chr_ in chromosomes:
    weights_by_chr_MA[chr_] = topMA_weights.filter(topMA_weights.locus.contig == chr_)
    print(f"Chromosome {chr_}: {weights_by_chr_MA[chr_].count()} SNPs")

# Save to bucket for downstream analysis
for chr_ in chromosomes:
    out = f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/weights_MA_chr{chr_}.ht'

    weights_by_chr_MA[chr_].write(out, overwrite=True)

    print(f"Wrote weights for {chr_}")

# ---- If Want to Write in Loop (skips any that have been done) ----
for chr_ in chromosomes:
    out = f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MT_chr{chr_}.ht'

    # Skip if already written (prevents redoing chr1 ever again)
    if hl.hadoop_exists(out):
        print(f"{chr_} already exists, skipping")
        continue

    mt_chr = SNP_data_mt.filter_rows(
        SNP_data_mt.locus.contig == chr_
    )

    n_rows, n_cols = mt_chr.count()
    print(f"Chromosome {chr_}: {n_rows} variants, {n_cols} samples")

    mt_chr.write(out)

# =====================================================
# 8. Save Final Cohort MT and Export to PLINK
# =====================================================

# Save to workspace bucket
SNP_data_mt.write('gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/data/SNP_data.mt', overwrite=True)

# Confirm it saved
!gsutil ls gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/data/

# ---- Convert Cohort Filtered Hail MT to PLINK Files ----
SNP_data_mt = hl.read_matrix_table(
    "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/data/SNP_data.mt"
)

# ---- Export PLINK Files ----
out_path = f"{bucket}/data/SNP_data_plink"

hl.export_plink(
    SNP_data_mt,
    out_path,
    ind_id=SNP_data_mt.s,
    fam_id=SNP_data_mt.s
)

# Check PLINK sample count
SNP_data_mt.count()[1]
