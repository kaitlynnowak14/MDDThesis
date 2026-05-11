# ============================================================
# Title: Polygenic Score SNP Overlap Pipeline (PGRN-AMPS Cohort)
# Dataset: PGRN-AMPS Imputed Genotypes (hg19)
#
# Description:
#   - Loads raw dbGaP phenotype file
#   - Filters excluded and low-quality participants
#   - Reports SNP overlap counts per chromosome
#   - Handles autosomes and chr X separately
#
# Output:
#   PRS-restricted VCF files (EA & MA)
#   EA and MA PRS weights files (GRCh37 coordinates)
# =============================================================

# =====================================================
# 1. CREATE BED FILES FROM WEIGHTS FILES FOR BOTH EA AND MA
# =====================================================

# ---- EA ----
awk 'NR>1 {print $2"\t"($3-1)"\t"$3}' TopEA_SNPs_GRCh37_weights.txt > EA_weights_snps.bed

# ---- MA ----
awk 'NR>1 {print $2"\t"($3-1)"\t"$3}' TopMA_SNPs_GRCh37_weights.txt > MA_weights_snps.bed

# =====================================================
# 2. EA SNP OVERLAP
# =====================================================

# ---- EA PRS Overlap Filtering ----
# Autosomes
for chr in {1..22}; do
    echo "Filtering chr${chr} to weights SNPs..."
    bcftools view -R EA_weights_snps.bed \
        PGRN_AMPS_autosomes_imputed_chr${chr}.filtered.vcf.gz \
        -Oz \
        -o PGRN_AMPS_autosomes_imputed_chr${chr}.filtered_EA_weights.vcf.gz

    bcftools index PGRN_AMPS_autosomes_imputed_chr${chr}.filtered_EA_weights.vcf.gz

    overlap=$(bcftools view -H -R EA_weights_snps.bed \
        PGRN_AMPS_autosomes_imputed_chr${chr}.filtered.vcf.gz | wc -l)
    echo "chr${chr} overlap with weights: $overlap SNPs"
done

# Chr X (merge males + females first)
bcftools merge -m none \
    PGRN_AMPS_chrX_males_ACAN.vcf.gz \
    PGRN_AMPS_chrX_females_ACAN.vcf.gz \
    -Oz -o PGRN_AMPS_chrX_ACAN_merged.vcf.gz
bcftools index PGRN_AMPS_chrX_ACAN_merged.vcf.gz

# Filter merged chrX
echo "Filtering merged chrX to weights SNPs..."
bcftools view -R EA_weights_snps.bed \
    PGRN_AMPS_chrX_ACAN_merged.vcf.gz \
    -Oz -o PGRN_AMPS_chrX_ACAN_filtered_EA_weights.vcf.gz
bcftools index PGRN_AMPS_chrX_ACAN_filtered_EA_weights.vcf.gz

overlap=$(bcftools view -H -R EA_weights_snps.bed \
    PGRN_AMPS_chrX_ACAN_merged.vcf.gz | wc -l)
echo "chrX overlap with weights: $overlap SNPs"

# =====================================================
# 3. MA SNP OVERLAP
# =====================================================

# Autosomes
for chr in {1..22}; do
    echo "Filtering chr${chr} to MA weights SNPs..."
    bcftools view -R MA_weights_snps.bed \
        PGRN_AMPS_autosomes_imputed_chr${chr}.filtered.vcf.gz \
        -Oz \
        -o PGRN_AMPS_autosomes_imputed_chr${chr}.filtered_MA_weights.vcf.gz

    bcftools index PGRN_AMPS_autosomes_imputed_chr${chr}.filtered_MA_weights.vcf.gz

    overlap=$(bcftools view -H -R MA_weights_snps.bed \
        PGRN_AMPS_autosomes_imputed_chr${chr}.filtered.vcf.gz | wc -l)
    echo "chr${chr} overlap with MA weights: $overlap SNPs"
done

# Chr X
echo "Filtering merged chrX to MA weights SNPs..."
bcftools view -R MA_weights_snps.bed \
    PGRN_AMPS_chrX_ACAN_merged.vcf.gz \
    -Oz -o PGRN_AMPS_chrX_ACAN_filtered_MA_weights.vcf.gz
bcftools index PGRN_AMPS_chrX_ACAN_filtered_MA_weights.vcf.gz

overlap=$(bcftools view -H -R MA_weights_snps.bed \
    PGRN_AMPS_chrX_ACAN_merged.vcf.gz | wc -l)
echo "chrX overlap with MA weights: $overlap SNPs"
