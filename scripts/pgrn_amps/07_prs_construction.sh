# ============================================================
# Title: Polygenic Risk Score Construction (PGRN-AMPS Cohort)
# Dataset: PGRN-AMPS Imputed Genotypes (hg19)
#
# Description:
#   -Merges EA & MA PRS-overlapping variants across autosomes
#   - Standardizes variant IDs
#   - Converts VCF -> PLINK format
#   - Handles chromosome X separately
#   - Computes final polygenic risk scores
#
# Output:
#   PLINK datasets
#   Final PRS score files
# =============================================================

# =====================================================
# 1. EA PRS CONSTRUCTION
# =====================================================

# ---- Merge Autosomal VCFs ----
# EA autosomes
bcftools concat \
    PGRN_AMPS_autosomes_imputed_chr{1..22}.filtered_EA_weights.vcf.gz \
    -Oz -o PGRN_AMPS_autosomes_all_EA_weights.vcf.gz

bcftools index PGRN_AMPS_autosomes_all_EA_weights.vcf.gz

# ---- Standardize Variant IDs ----
# Autosomes
bcftools annotate \
  --set-id '%CHROM:%POS' \
  PGRN_AMPS_autosomes_all_EA_weights.vcf.gz \
  -Oz -o PGRN_AMPS_autosomes_all_EA_weights.id.vcf.gz

bcftools index PGRN_AMPS_autosomes_all_EA_weights.id.vcf.gz

# Chr X
bcftools annotate \
  --set-id '%CHROM:%POS' \
  PGRN_AMPS_chrX_ACAN_filtered_EA_weights.vcf.gz \
  -Oz -o PGRN_AMPS_chrX_EA_weights.id.vcf.gz

bcftools index PGRN_AMPS_chrX_EA_weights.id.vcf.gz

# Quick check
bcftools query -f '%ID\n' PGRN_AMPS_autosomes_all_EA_weights.id.vcf.gz | head

# ---- Convert VCFs -> PLINK Format ----
# Autosomes
plink \
  --vcf PGRN_AMPS_autosomes_all_EA_weights.id.vcf.gz \
  --double-id \
  --make-bed \
  --out EA_autosomes

# Chr X
plink \
  --vcf PGRN_AMPS_chrX_EA_weights.id.vcf.gz \
  --double-id \
  --make-bed \
  --out EA_chrX

# ---- Create PLINK Scoring File Using Weights ----
awk 'NR>1 {print $2":"$3"\t"$4"\t"$6}' \
  TopEA_SNPs_GRCh37_weights.txt > EA_weights.plink

head EA_weights.plink

# ---- Fix ChrX BIM & Align Weights ----
awk '{
  new_id = $1 ":" $4 ":" $5 ":" $6
  print $1, new_id, $3, $4, $5, $6
}' OFS="\t" EA_chrX.bim > EA_chrX.fixed.bim

mv EA_chrX.bim EA_chrX.bim.backup
mv EA_chrX.fixed.bim EA_chrX.bim

# Create Chr X weight file with alleles in ID position
## Extract Chr X from weights file
awk 'NR==1 || $2==23' TopEA_SNPs_GRCh37_weights.txt > EA_weights_chrX.txt

# Create PLINK file
awk 'NR>1 {print $2":"$3":"$4":"$5, $4, $6}' EA_weights_chrX.txt > EA_weights_chrX.plink

# ---- PRS Scoring EA ----
# Autosomes
plink \
  --bfile EA_autosomes \
  --score EA_weights.plink 1 2 3 sum \
  --out PRS_EA_autosomes

# Chr X
plink \
  --bfile EA_chrX \
  --score EA_weights_chrX.plink 1 2 3 sum \
  --out PRS_EA_chrX

# =====================================================
# 2. MA PRS CONSTRUCTION
# =====================================================

# ---- Merge Autosomal VCFs ----
bcftools concat \
    PGRN_AMPS_autosomes_imputed_chr{1..22}.filtered_MA_weights.vcf.gz \
    -Oz -o PGRN_AMPS_autosomes_all_MA_weights.vcf.gz

bcftools index PGRN_AMPS_autosomes_all_MA_weights.vcf.gz

# ---- Standardize Variant IDs ----
# Autosomes
bcftools annotate \
  --set-id '%CHROM:%POS' \
  PGRN_AMPS_autosomes_all_MA_weights.vcf.gz \
  -Oz -o PGRN_AMPS_autosomes_all_MA_weights.id.vcf.gz

bcftools index PGRN_AMPS_autosomes_all_MA_weights.id.vcf.gz

# Chr X
bcftools annotate \
  --set-id '%CHROM:%POS' \
  PGRN_AMPS_chrX_ACAN_filtered_MA_weights.vcf.gz \
  -Oz -o PGRN_AMPS_chrX_MA_weights.id.vcf.gz

bcftools index PGRN_AMPS_chrX_MA_weights.id.vcf.gz

# CHECK
bcftools query -f '%ID\n' PGRN_AMPS_autosomes_all_MA_weights.id.vcf.gz | head

# ---- Convert VCFs -> PLINK Format ----
# Autosomes
plink \
  --vcf PGRN_AMPS_autosomes_all_MA_weights.id.vcf.gz \
  --double-id \
  --make-bed \
  --out MA_autosomes

# Chr X
plink \
  --vcf PGRN_AMPS_chrX_MA_weights.id.vcf.gz \
  --double-id \
  --make-bed \
  --out MA_chrX

# ---- Create PLINK Scoring File Using Weights ----
awk 'NR>1 {print $2":"$3"\t"$4"\t"$6}' \
  TopMA_SNPs_GRCh37_weights.txt > MA_weights.plink

head MA_weights.plink

# ---- Fix ChrX BIM & Align Weights ----
awk '{
  new_id = $1 ":" $4 ":" $5 ":" $6
  print $1, new_id, $3, $4, $5, $6
}' OFS="\t" MA_chrX.bim > MA_chrX.fixed.bim

mv MA_chrX.bim MA_chrX.bim.backup
mv MA_chrX.fixed.bim MA_chrX.bim

# Create Chr X weight file with alleles in ID position
## Extract Chr X from weights file
awk 'NR==1 || $2==23' TopMA_SNPs_GRCh37_weights.txt > MA_weights_chrX.txt

# Create PLINK file
awk 'NR>1 {print $2":"$3":"$4":"$5, $4, $6}' MA_weights_chrX.txt > MA_weights_chrX.plink

# ---- PRS Scoring MA ----
# Autosomes
plink \
  --bfile MA_autosomes \
  --score MA_weights.plink 1 2 3 sum \
  --out PRS_MA_autosomes

# Chr X
plink \
  --bfile MA_chrX \
  --score MA_weights_chrX.plink 1 2 3 sum \
  --out PRS_MA_chrX
