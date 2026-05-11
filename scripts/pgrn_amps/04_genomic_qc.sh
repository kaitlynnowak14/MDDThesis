# ============================================================
# Title: Genotype Quality Control Pipeline (PGRN-AMPS Cohort)
# Dataset: PGRN-AMPS dbGaP Genotype Data (phs000670)
#
# Description:
#   - Performs standard PLINK QC (MAF, HWE, missingness filtering)
#   - Removes related individuals
#   - Converts genome build (hg18 -> hg19 via liftover)
#   - Produces final QC-ready genotype dataset for PRS analyses
#
# Output:
#   PGRN_AMPS_QC_unrelated_hg19_final
#
# Notes: 
#   - Ensures hamonized genotype build and unrelated sample set
#   - !/bin/bash
# =============================================================

# =====================================================
# 1. SET BASE DIRECTORY
# =====================================================

BASE_DIR="/Users/knowak/Desktop/PGRN-AMPS/Files Needed for Analyses/genotype_matrix/sub/sub20131107"
cd "$BASE_DIR"

# =====================================================
# 2. INITIAL GENOTYPE QC (MAF/HWE/MISSINGNESS)
# =====================================================

# ---- MAF, HWE, Genotyping Rate ----
plink --bfile SSRIdbGaP\
      --keep SUBJIDs_to_keep.txt \
      --maf 0.01 \
      --geno 0.02 \
      --hwe 1e-6 \
      --make-bed \
      --out PGRN_AMPS_QC

# ---- Relatedness Filtering ----
# Compute pairwise relatedness
plink --bfile PGRN_AMPS_QC \
      --genome \
      --min 0.185 \
      --out ibd

# Extract related pairs
awk '$10 > 0.185 {print $1, $2, $3, $4}' ibd.genome | awk 'NF==4' > related_pairs_clean.txt
tail -n +2 related_pairs_clean.txt > related_pairs_noheader.txt

# Randomly select one from each pair to remove
awk 'BEGIN{srand()} { 
  if (rand() < 0.5) print $1, $2; 
  else print $3, $4 
}' related_pairs_noheader.txt > remove_related_random.txt

# Remove selected individuals
plink --bfile PGRN_AMPS_QC \
      --remove remove_related_random.txt \
      --make-bed \
      --out PGRN_AMPS_QC_unrelated

# ---- Post-relatedness QC Checks ----
# Check final female/male counts (1 = male, 2 = female)
awk '{print $5}' PGRN_AMPS_QC_unrelated.fam | sort | uniq -c

# Post-relatedness missingness check
plink --bfile PGRN_AMPS_QC_unrelated --missing --out missingness_post_related

# =====================================================
# 3. LIFTOVER
# =====================================================

# ---- Create BED File ----
awk '{
  chr=$1
  if(chr==23) chr="X"
  print "chr"chr, $4-1, $4, $2
}' OFS="\t" PGRN_AMPS_QC_unrelated.bim > PGRN_AMPS_QC_unrelated_hg18.bed

# ---- Download Liftover Tools ----
# Make sure chain file exists
wget -N http://hgdownload.cse.ucsc.edu/goldenpath/hg18/liftOver/hg18ToHg19.over.chain.gz
gunzip -f hg18ToHg19.over.chain.gz

# Use UCSC liftover
wget http://hgdownload.cse.ucsc.edu/admin/exe/macOSX.x86_64/liftOver
chmod +x liftOver

# ---- Run Liftover ----
./liftOver PGRN_AMPS_QC_unrelated_hg18.bed hg18ToHg19.over.chain \
           PGRN_AMPS_QC_unrelated_hg19.bed \
           PGRN_AMPS_QC_unrelated_unmapped.bed

# ---- Create Liftover Mapping File ----
# Create SNP ID → new chr/position map
awk '{chr=$1; sub(/^chr/, "", chr); print $4, chr, $2+1}' \
    PGRN_AMPS_QC_unrelated_hg19.bed > liftover_map.txt

# ---- Update BIM Coordinates ----
awk 'NR==FNR {a[$1]=$2"\t"$3; next} $2 in a {print a[$2], $2, $3, $4, $5, $6}' \
    liftover_map.txt PGRN_AMPS_QC_unrelated.bim > PGRN_AMPS_QC_unrelated_hg19.bim

# Fix file, so now only hg19 coordinates present
awk '{print $1, $3, $4, $2, $6, $7}' OFS="\t" PGRN_AMPS_QC_unrelated_hg19.bim > PGRN_AMPS_QC_unrelated_hg19_fixed.bim

# Confirm file is fixed
head PGRN_AMPS_QC_unrelated_hg19_fixed.bim 

# ---- Build Final Lifted Dataset ----
# Extract only SNPs that successfully lifted
awk '{print $4}' PGRN_AMPS_QC_unrelated_hg19.bed > snps_lifted.txt

# Create a new PLINK dataset with onyl SNPs that successfully lifted
plink --bfile PGRN_AMPS_QC_unrelated \
      --extract snps_lifted.txt \
      --make-bed \
      --out PGRN_AMPS_QC_unrelated_hg19_safe

# Replace BIM with newly updated hg19 coordinates file, but make sure names match across BIM, FAM, and BED
cp PGRN_AMPS_QC_unrelated_hg19_fixed.bim PGRN_AMPS_QC_unrelated_hg19_safe.bim

# =====================================================
# 4. STRAND ALIGNMENT
# =====================================================

plink --bfile PGRN_AMPS_QC_unrelated_hg19_safe \
      --flip flip.txt \
      --make-bed \
      --out PGRN_AMPS_QC_unrelated_hg19_flipped

# ---- Remove Stand-Ambiguous SNPs ----
# Identify strans-ambiguous SNPs
awk '{if (($5=="A" && $6=="T")||($5=="T" && $6=="A")||($5=="C" && $6=="G")||($5=="G" && $6=="C")) print $2}' \
    PGRN_AMPS_QC_unrelated_hg19_flipped.bim > snps_ambiguous.txt

# Sanity check: count how many SNPs are being removed
num_ambig=$(wc -l < snps_ambiguous.txt)
echo "Number of strand-ambiguous SNPs removed: $num_ambig"

# Remove ambiguous SNPs
plink --bfile PGRN_AMPS_QC_unrelated_hg19_flipped \
      --exclude snps_ambiguous.txt \
      --make-bed \
      --out PGRN_AMPS_QC_unrelated_hg19_noambig

# =====================================================
# 5. FINAL POST-LIFTOVER FILTERING
# =====================================================
plink --bfile PGRN_AMPS_QC_unrelated_hg19_noambig \
      --geno 0.02 \
      --make-bed \
      --out PGRN_AMPS_QC_unrelated_hg19_final

# =====================================================
# 6. FINAL QC SUMMARY CHECK
# =====================================================
# Gives allele frequencies and missingness per SNP/sample for final QC verification
plink --bfile PGRN_AMPS_QC_unrelated_hg19_final \
      --freq \
      --missing \
      --out post_liftover_qc
