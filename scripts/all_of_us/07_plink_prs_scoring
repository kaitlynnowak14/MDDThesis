# ============================================================
# Title: PRS Genotype Processing & Polygenic Risk Scoring
# Dataset: All of Us Controlled Tier (WGS Subset)
#
# Description:
#   - Export chromosome-level MatrixTables to VCF
#   - Convert cleaned genotype data to PLINK format
#   - Merge chromosomes into genome-wide dataset
#   - Generate PRS scoring weights file
#   - Compute educational attainment polygenic risk scores
#
# Output:
#   AoU_all_clean.{bed,bim,fam}
#   EA_weights_for_plink.txt
#   EA_PRS_results.profile
#   AoU_MA_all_clean.{bed,bim,fam}
#   MA_weights_for_plink.txt
#   MA_PRS_results.profile
#
# Notes:
#   - Uses GRCh38 reference genome
#   - Removes duplicate variants prior to PLINK conversion
#   - Final PRS generated using PLINK --score
# ============================================================

# =====================================================
# 0. SET UP
# =====================================================

# ---- Import & Initialize Hail
import hail as hl
import os
import subprocess
import pandas as pd

hl.init(default_reference='GRCh38')

# ---- Define Chromosomes ----
chromosomes = [f"chr{i}" for i in range(1, 23)] + ["chrX"]

# =====================================================
# 1. PLINK PRS Scoring EA
# =====================================================

# ---- Export MatrixTables to VCF ----
for chr_ in chromosomes:
    print(f"Exporting {chr_}")
    
    mt = hl.read_matrix_table(
        f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MT_chr{chr_}_Overlap_locusOnly.ht'
    )

    hl.export_vcf(
        mt,
        f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/AoU_{chr_}.vcf.bgz'
    )
# Manual re-export for chr 1
mt = hl.read_matrix_table(
    f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MT_chrchr1_Overlap_locusOnly.ht'
)

hl.export_vcf(
    mt,
    f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/AoU_chr1.vcf.bgz'
)

# ---- Copy VCFs to Local Workspace ----
for chr_ in chromosomes:
    print(f"Copying {chr_}")
    !gsutil cp \
        gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/AoU_{chr_}.vcf.bgz \
        .

# Confirm files exist locally
!ls

# ---- Standardize Variant IDs ----
for chr_ in chromosomes:
    print(f"Standardizing {chr_}")

    # Set SNP ID format to CHR:POS
    subprocess.run([
        "bcftools", "annotate",
        "--set-id", "%CHROM:%POS",
        f"AoU_{chr_}.vcf.bgz",
        "-Oz",
        "-o", f"AoU_{chr_}.id.vcf.bgz"
    ], check=True)

    # Index standardized VCF
    subprocess.run([
        "bcftools", "index",
        f"AoU_{chr_}.id.vcf.bgz"
    ], check=True)

# ---- Remove Duplicate Variants ----
for chr_ in chromosomes:
    print(f"Removing duplicates for chromosome {chr_}...")

    # Input VCF
    input_vcf = f"AoU_{chr_}.id.vcf.bgz"
    # Output VCF with duplicates removed
    output_vcf = f"AoU_{chr_}.nodup.vcf.bgz"

    # Use bcftools to remove duplicates
    subprocess.run([
        "bcftools", "norm",
        "-d", "both",  # remove duplicate IDs
        input_vcf,
        "-Oz",
        "-o", output_vcf
    ], check=True)

    # Index cleaned VCF
    subprocess.run([
        "bcftools", "index",
        output_vcf
    ], check=True)

    print(f"Chromosome {chr_} duplicates removed → {output_vcf}")

# ---- Convert VCFs to PLINK Format ----
for chr_ in chromosomes:
    print(f"Converting {chr_} to PLINK")

    subprocess.run([
        "plink",
        "--vcf", f"AoU_{chr_}.nodup.vcf.bgz",
        "--double-id",
        "--snps-only", "just-acgt",
        "--biallelic-only", "strict",
        "--make-bed",
        "--out", f"AoU_{chr_}_raw"
    ], check=True)

# Confirm BIM formatting 
!head AoU_chr1_raw.bim

# ---- Merge Chromosomes into Genome-wide Dataset ----
chromosomes = [f"chr{i}" for i in range(2,23)] + ["chrX"]

with open("merge_list.txt", "w") as f:
    for chr_ in chromosomes:
        f.write(f"AoU_{chr_}_raw\n")

!plink \
  --bfile AoU_chr1_raw \
  --merge-list merge_list.txt \
  --make-bed \
  --out AoU_all_clean

# ---- Save Clean PLINK Files to Bucket ----
# Set your bucket path
BUCKET_PATH = "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/clean_plink"

# Upload all four main files
!gsutil cp AoU_all_clean.bed $BUCKET_PATH/
!gsutil cp AoU_all_clean.bim $BUCKET_PATH/
!gsutil cp AoU_all_clean.fam $BUCKET_PATH/
!gsutil cp AoU_all_clean.nosex $BUCKET_PATH/

# ---- Load EA Weights Files ----
# Inspect chrX
path = "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/weights_chrchrX.ht"

ht_chrX = hl.read_table(path)

ht_chrX.show(10)

# Load & merge all weight tables
chromosomes = [f"chr{i}" for i in range(1, 23)] + ["chrX"]

w_base = "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/weights_chr{chr}.ht"

ht_all = None

for chr_ in chromosomes:
    path = w_base.format(chr=chr_)
    print("Loading:", path)

    ht = hl.read_table(path)

    if ht_all is None:
        ht_all = ht
    else:
        ht_all = ht_all.union(ht)

# Confirm combined weights
ht_all.show(10)

# ---- Generate PLINK-Compatible SNP IDs ----
ht_all = ht_all.annotate(
    SNP_ID = (
        hl.if_else(
            ht_all.locus.contig == "X",
            "23",
            ht_all.locus.contig
        ) + ":" +
        hl.str(ht_all.locus.position)
    )
)

# Confirm SNP IDs
ht_all.show(10)

# ---- Create PLINK Scoring File ----
EA_weights_plink = ht_all.select(
    "SNP_ID",
    effect_allele = ht_all.a1,
    beta = ht_all.weight
)

EA_weights_final = (
    EA_weights_plink
    .key_by()   # removes locus/alleles as key
    .select(
        "SNP_ID",
        "effect_allele",
        "beta"
    )
)

# Export scoring weights file
EA_weights_final.export("EA_weights_for_plink.txt")

# Inspect final weights file
EA_weights_final.describe()

EA_weights_final.show(10)

# Confirm BIM structure
!head AoU_all_clean.bim

# ---- Save Final Files to Bucket ----
!gsutil cp AoU_all_clean.bed gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/
!gsutil cp AoU_all_clean.bim gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/
!gsutil cp AoU_all_clean.fam gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/

EA_weights_final.export(
    "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/EA_weights_for_plink.txt"
)

# ---- Copy Final Files Back to Local Workspace ----
!gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/AoU_all_clean.bed .
!gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/AoU_all_clean.bim .
!gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/AoU_all_clean.fam .

!gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/EA_weights_for_plink.txt .

# ---- Compute Polygenic Risk Scores ----
!plink \
  --bfile AoU_all_clean \
  --score EA_weights_for_plink.txt 1 2 3 sum \
  --out EA_PRS_results

# Inspect PRS Output
!head EA_PRS_results.profile

!wc -l EA_PRS_results.profile

# ---- Save PRS Results to Bucket ----
!gsutil cp EA_PRS_results.* gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/

# =====================================================
# 2. PLINK PRS Scoring MA (same code, just MA files)
# =====================================================

# ---- Export MatrixTables to VCF ----
for chr_ in chromosomes:
    print(f"Exporting {chr_}")
    
    MA_mt = hl.read_matrix_table(
        f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MT_chr{chr_}_MA_Overlap_locusOnly.ht'
    )

    hl.export_vcf(
        MA_mt,
        f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/AoU_{chr_}_MA.vcf.bgz'
    )

# ---- Copy VCFs to Local Workspace ----
for chr_ in chromosomes:
    print(f"Copying {chr_}")
    !gsutil cp \
        gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/AoU_{chr_}_MA.vcf.bgz \
        .

# Confirm files exist locally
!ls

# ---- Standardize Variant IDs ----
for chr_ in chromosomes:
    print(f"Standardizing {chr_}")

    # Set ID to CHR:POS
    subprocess.run([
        "bcftools", "annotate",
        "--set-id", "%CHROM:%POS",
        f"AoU_{chr_}_MA.vcf.bgz",
        "-Oz",
        "-o", f"AoU_{chr_}_MA.id.vcf.bgz"
    ], check=True)

    # Index the new VCF
    subprocess.run([
        "bcftools", "index",
        f"AoU_{chr_}_MA.id.vcf.bgz"
    ], check=True)

# ---- Remove Duplicate Variants ----
for chr_ in chromosomes:
    print(f"Removing duplicates for chromosome {chr_}...")

    # Input VCF (already split)
    MA_input_vcf = f"AoU_{chr_}_MA.id.vcf.bgz"
    # Output VCF with duplicates removed
    MA_output_vcf = f"AoU_{chr_}_MA.nodup.vcf.bgz"

    # Use bcftools to remove duplicates
    subprocess.run([
        "bcftools", "norm",
        "-d", "both",  # remove duplicate IDs
        MA_input_vcf,
        "-Oz",
        "-o", MA_output_vcf
    ], check=True)

    # Index the cleaned VCF
    subprocess.run([
        "bcftools", "index",
        MA_output_vcf
    ], check=True)

    print(f"Chromosome {chr_} duplicates removed → {MA_output_vcf}")

# ---- Convert VCFs to PLINK Format ----
for chr_ in chromosomes:
    print(f"Converting {chr_} to PLINK")

    subprocess.run([
        "plink",
        "--vcf", f"AoU_{chr_}_MA.nodup.vcf.bgz",
        "--double-id",
        "--snps-only", "just-acgt",
        "--biallelic-only", "strict",
        "--make-bed",
        "--out", f"AoU_{chr_}_MA_raw"
    ], check=True)

# Confirm BIM formatting 
!head AoU_chr1_MA_raw.bim

# ---- Merge Chromosomes into Genome-wide Dataset ----
chromosomes = [f"chr{i}" for i in range(2,23)] + ["chrX"]

with open("MA_merge_list.txt", "w") as f:
    for chr_ in chromosomes:
        f.write(f"AoU_{chr_}_MA_raw\n")

!plink \
  --bfile AoU_chr1_MA_raw \
  --merge-list MA_merge_list.txt \
  --make-bed \
  --out AoU_MA_all_clean

# ---- Save Clean PLINK Files to Bucket ----
# Set your bucket path
BUCKET_PATH = "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b"

# Upload all four main files
!gsutil cp AoU_MA_all_clean.bed $BUCKET_PATH/
!gsutil cp AoU_MA_all_clean.bim $BUCKET_PATH/
!gsutil cp AoU_MA_all_clean.fam $BUCKET_PATH/
!gsutil cp AoU_MA_all_clean.nosex $BUCKET_PATH/

# ---- Load EA Weights Files ----
# Inspect chrX
path = "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/weights_MA_chrchrX.ht"

ht_MA_chrX = hl.read_table(path)

ht_MA_chrX.show(10)

# Load & merge all weight tables
chromosomes = [f"chr{i}" for i in range(1, 23)] + ["chrX"]

w_MA_base = "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/weights_MA_chr{chr}.ht"

ht_MA_all = None

for chr_ in chromosomes:
    path = w_MA_base.format(chr=chr_)
    print("Loading:", path)

    ht_MA = hl.read_table(path)

    if ht_MA_all is None:
        ht_MA_all = ht_MA
    else:
        ht_MA_all = ht_MA_all.union(ht_MA)

# Confirm combined weights
ht_MA_all.show(10)

# ---- Generate PLINK-Compatible SNP IDs ----
ht_MA_all = ht_MA_all.annotate(
    SNP_ID = (
        hl.if_else(
            ht_MA_all.locus.contig == "X",
            "23",
            ht_MA_all.locus.contig
        ) + ":" +
        hl.str(ht_MA_all.locus.position)
    )
)

# Confirm SNP IDs
ht_MA_all.show(10)

# ---- Create PLINK Scoring File ----
MA_weights_plink = ht_MA_all.select(
    "SNP_ID",
    effect_allele = ht_MA_all.a1,
    beta = ht_MA_all.weight
)

MA_weights_final = (
    MA_weights_plink
    .key_by()   # removes locus/alleles as key
    .select(
        "SNP_ID",
        "effect_allele",
        "beta"
    )
)

# Export scoring weights file
MA_weights_final.export("MA_weights_for_plink.txt")

# Inspect final weights file
MA_weights_final.describe()

MA_weights_final.show(10)

# Confirm BIM structure
!head AoU_MA_all_clean.bim

# ---- Save Final Files to Bucket ----
!gsutil cp AoU_MA_all_clean.bed gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/
!gsutil cp AoU_MA_all_clean.bim gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/
!gsutil cp AoU_MA_all_clean.fam gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/

MA_weights_final.export(
    "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MA_weights_for_plink.txt"
)

# ---- Copy Final Files Back to Local Workspace ----
!gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/AoU_MA_all_clean.bed .
!gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/AoU_MA_all_clean.bim .
!gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/AoU_MA_all_clean.fam .

!gsutil cp gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MA_weights_for_plink.txt .

# ---- Compute Polygenic Risk Scores ----
!plink \
  --bfile AoU_MA_all_clean \
  --score MA_weights_for_plink.txt 1 2 3 sum \
  --out MA_PRS_results

# Inspect PRS Output
!head MA_PRS_results.profile

!wc -l MA_PRS_results.profile

# ---- Save PRS Results to Bucket ----
!gsutil cp MA_PRS_results.* gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/
