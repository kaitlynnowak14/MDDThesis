# ============================================================
# Title: Genotype Imputation Pipeline (PGRN-AMPS Cohort)
# Dataset: PGRN-AMPS post-qc hg-19 genotypes
#
# Description:
#   - Splits autosomes and sex chromosomes
#   - Converts PLINK -> VCF format
#   - Annotates VCFs
#   - Performs phasing using SHAPEIT5
#   - Runs genotype imputation using MINIMAC4
#   - Applies post-imputation QC filters
#
# Dependencies:
#   - PLINK
#   - bcftools/tabix
#   - Docker (SHAPEIT5, MINIMAC4)
#   - 1000 Genomes Phase 3 reference panel
#
# Output: 
#   - Phased BCF files
#   - Imputed VCF files (per chromosome)
#   - QC-filtered imputed dataset
# =============================================================

# =====================================================
# 1. SPLIT AUTOSOMES & CHROMOSOME X
# =====================================================

# ---- Autosomes ----
plink --bfile PGRN_AMPS_QC_unrelated_hg19_final \
      --chr 1-22 \
      --make-bed \
      --out PGRN_AMPS_QC_autosomes

# ---- ChrX (Females) ----
awk '$5==2 {print $1, $2}' PGRN_AMPS_QC_unrelated_hg19_final.fam > females.txt
plink --bfile PGRN_AMPS_QC_unrelated_hg19_final \
      --chr X \
      --keep females.txt \
      --make-bed \
      --out PGRN_AMPS_QC_chrX_females

# ---- ChrX (Males) ----
awk '$5==1 {print $1, $2}' PGRN_AMPS_QC_unrelated_hg19_final.fam > males.txt
plink --bfile PGRN_AMPS_QC_unrelated_hg19_final \
      --chr X \
      --keep males.txt \
      --make-bed \
      --out PGRN_AMPS_QC_chrX_males

# =====================================================
# 2. CONVERT PLINK -> VCF
# =====================================================

# Autosomes
plink --bfile PGRN_AMPS_QC_autosomes \
      --recode vcf bgz \
      --out PGRN_AMPS_autosomes

# Chr X - females
plink --bfile PGRN_AMPS_QC_chrX_females \
      --recode vcf bgz \
      --out PGRN_AMPS_chrX_females

# Chr X - males
plink --bfile PGRN_AMPS_QC_chrX_males \
      --recode vcf bgz \
      --out PGRN_AMPS_chrX_males


# =====================================================
# 3. INDEX VCF FILES
# =====================================================

tabix -p vcf PGRN_AMPS_autosomes.vcf.gz
tabix -p vcf PGRN_AMPS_chrX_females.vcf.gz
tabix -p vcf PGRN_AMPS_chrX_males.vcf.gz


# =====================================================
# 4. DOWNLOAD SOFTWARE
# =====================================================

# ---- 1000 Genomes Phase 3 Reference ----
mkdir -p ~/PGRN-AMPS/1000G
cd ~/PGRN-AMPS/1000G

# All autosomes in a loop
for chr in {1..22} X; do
    wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr${chr}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz
    wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr${chr}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz.tbi
done

# Chr X separately with different version
wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz
wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz.tbi

# Check VCF contents
zcat ALL.chr22.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz | head -n 20


# ---- Genetic Mapping Files (GRCh37) ----
# Can download at this link: https://github.com/odelaneau/shapeit4/blob/master/maps/genetic_maps.b37.tar.gz 
cd ~/Downloads
tar -xvzf genetic_maps.b37.tar.gz


# =====================================================
# 5. ANNOTATE VCFS
# =====================================================

# Autosomes
bcftools +fill-tags PGRN_AMPS_autosomes.vcf.gz -Oz -o PGRN_AMPS_autosomes_AC.vcf.gz -- -t AC,AF
bcftools index PGRN_AMPS_autosomes_AC.vcf.gz

# ChrX - females
bcftools +fill-tags PGRN_AMPS_chrX_females.vcf.gz -Oz -o PGRN_AMPS_chrX_females_AC.vcf.gz -- -t AC,AF
bcftools index PGRN_AMPS_chrX_females_AC.vcf.gz

# ChrX - males
bcftools +fill-tags PGRN_AMPS_chrX_males.vcf.gz -Oz -o PGRN_AMPS_chrX_males_AC.vcf.gz -- -t AC,AF
bcftools index PGRN_AMPS_chrX_males_AC.vcf.gz

# AN part
bcftools +fill-tags PGRN_AMPS_autosomes.vcf.gz \
    -Oz -o PGRN_AMPS_autosomes_ACAN.vcf.gz \
    -- -t AN,AC
bcftools index PGRN_AMPS_autosomes_ACAN.vcf.gz

bcftools +fill-tags PGRN_AMPS_chrX_females.vcf.gz \
    -Oz -o PGRN_AMPS_chrX_females_ACAN.vcf.gz \
    -- -t AN,AC
bcftools index PGRN_AMPS_chrX_females_ACAN.vcf.gz

bcftools +fill-tags PGRN_AMPS_chrX_males.vcf.gz \ 
    -Oz -o PGRN_AMPS_chrX_males_ACAN.vcf.gz \ 
    -- -t AN,AC
bcftools index PGRN_AMPS_chrX_males_ACAN.vcf.gz 


# =====================================================
# 6. SHAPEIT5 PHASING (DOCKER - USING SHELL SCRIPT)
# =====================================================

nano run_shapeit5_phasing.sh

# ****************************************************************************************************
#!/bin/bash

# --------------------------
# Paths & Settings
# --------------------------
VCF_DIR="/Users/knowak/Desktop/PGRN-AMPS/Files Needed for Analyses/genotype_matrix/sub/sub20131107"
MAP_DIR="/Users/knowak/Downloads/genetic_maps.b37"
DOCKER_IMAGE="shapeit5_2023-05-05_d6ce1e2"
THREADS=4

# --------------------------
# Autosomes (chromosomes 1-22)
# --------------------------
CHROMS=( {1..22} )

for chr in "${CHROMS[@]}"; do
    echo "Phasing chromosome $chr ..."

    docker run --rm -it --platform linux/amd64 \
        -v "$VCF_DIR":/vcfs \
        -v "$MAP_DIR":/maps \
        $DOCKER_IMAGE \
        /usr/bin/phase_common_static \
            --input /vcfs/PGRN_AMPS_autosomes_ACAN.vcf.gz \
            --region $chr \
            --map /maps/chr${chr}.b37.gmap.gz \
            --output /vcfs/PGRN_AMPS_autosomes_phased_chr${chr}.bcf \
            --output-format bcf \
            --thread $THREADS \
            --progress

    echo "Finished chromosome $chr"
done

echo "All phasing complete!"
# ****************************************************************************************************

# make exectuable and run (back in command line)
chmod +x run_shapeit5_phasing.sh
./run_shapeit5_phasing.sh

# Run Chr X for males and females separately
nano run_shapeit5_phasing_chrX.sh

# Replace spaces with underscores in males.txt file
sed 's/ /_/g' males.txt > males_fixed.txt

# Subset VCF using corrected males.txt file
bcftools view -S males_fixed.txt -Oz -o PGRN_AMPS_chrX_males_haploid.vcf.gz PGRN_AMPS_chrX_males_ACAN.vcf.gz
bcftools index PGRN_AMPS_chrX_males_haploid.vcf.gz

# ****************************************************************************************************
#!/bin/bash

VCF_DIR="/Users/knowak/Desktop/PGRN-AMPS/Files Needed for Analyses/genotype_matrix/sub/sub20131107"
MAP_DIR="/Users/knowak/Downloads/genetic_maps.b37"
DOCKER_IMAGE="shapeit5_2023-05-05_d6ce1e2"
THREADS=4

# --------------------------
# ChrX - females
# --------------------------
echo "Phasing ChrX - females ..."
docker run --rm -it --platform linux/amd64 \
    -v "$VCF_DIR":/vcfs \
    -v "$MAP_DIR":/maps \
    $DOCKER_IMAGE \
    /usr/bin/phase_common_static \
        --input /vcfs/PGRN_AMPS_chrX_females_ACAN.vcf.gz \
        --map /maps/chrX.b37.gmap.gz \
        --output /vcfs/PGRN_AMPS_chrX_females_phased.bcf \
        --region 23 \
        --thread $THREADS \
        --progress

# --------------------------
# ChrX - males
# --------------------------
echo "Phasing ChrX - males ..."

docker run --rm -it --platform linux/amd64 \
    -v "$VCF_DIR":/vcfs \
    -v "$MAP_DIR":/maps \
    $DOCKER_IMAGE \
    /usr/bin/phase_common_static \
        --input /vcfs/PGRN_AMPS_chrX_males_haploid.vcf.gz \
        --haploid /vcfs/males_fixed.txt \
        --map /maps/chrX.b37.gmap.gz \
        --output /vcfs/PGRN_AMPS_chrX_males_phased.bcf \
        --region 23 \
        --thread $THREADS \
        --progress

echo "ChrX phasing complete!"
# ****************************************************************************************************

# make exectuable and run (back in command line)
chmod +x run_shapeit5_phasing_chrX.sh
./run_shapeit5_phasing_chrX.sh


# =====================================================
# 7. INDEX & FILTER
# =====================================================

# Index
bcftools index PGRN_AMPS_autosomes_phased_chr*.bcf # Repeat for all Chr
bcftools index PGRN_AMPS_chrX_females_phased.bcf
bcftools index PGRN_AMPS_chrX_males_phased.bcf

# Filter to only biallelic SNPs using loop over chromosomes 1–22 and X
nano filter_biallelic_all_chr.sh

# ****************************************************************************************************
#!/bin/bash

cd ~/PGRN-AMPS/1000G

for chr in {1..22} X; do
    echo "Filtering chr$chr to biallelic SNPs..."
    
    INVCF="ALL.chr${chr}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz"
    OUTVCF="ALL.chr${chr}.biallelic.vcf.gz"
    
    bcftools view -v snps -m2 -M2 "$INVCF" -Oz -o "$OUTVCF"
    bcftools index "$OUTVCF"
    
    echo "Done chr$chr"
done
# ****************************************************************************************************

# Make executable and run
chmod +x filter_biallelic_all_chr.sh

./filter_biallelic_all_chr.sh

# Redo Chr X because incorrect file name
bcftools view -v snps -m2 -M2 \
  ALL.chrX.phase3_shapeit2_mvncall_integrated_v1c.20130502.genotypes.vcf.gz \
  -Oz -o ALL.chrX.biallelic.vcf.gz

bcftools index ALL.chrX.biallelic.vcf.gz


# =====================================================
# 8. MINIMAC4 IMPUTATION
# =====================================================

# ---- Download MINIMAC4 & Run ----
docker run -it --platform linux/amd64 \
  -v "/Users/knowak/Desktop/PGRN-AMPS/Files Needed for Analyses/genotype_matrix/sub/sub20131107":/data \
  -v "/Users/knowak/PGRN-AMPS/1000G":/ref \
  -w /ref \
  minimac4

# Loop to compress all autosomes
for chr in {1..22}; do
    echo "Compressing chr$chr to MVCF..."
    minimac4 --compress-reference /ref/ALL.chr${chr}.biallelic.vcf.gz > /ref/chr${chr}.mvcf
    echo "Done chr$chr"
done

# ****************************************************************************************************
cd /data

cat > run_imputation_autosomes.sh << 'EOF'
#!/bin/bash

# Number of threads to use per chromosome
THREADS=4

# Loop over autosomes 1 to 22
for chr in {1..22}; do
    echo "Starting imputation for chr$chr..."

    # Input phased target
    TARGET="/data/PGRN_AMPS_autosomes_phased_chr${chr}.bcf"

    # Reference MVCF
    REF="/ref/chr${chr}.mvcf"

    # Output file
    OUT="/data/PGRN_AMPS_autosomes_imputed_chr${chr}.vcf.gz"

    # Run Minimac4
    minimac4 \
        --refHaps "$REF" \
        --haps "$TARGET" \
        --prefix "${OUT%.vcf.gz}" \
        --format GT,HDS,DS \
        --threads "$THREADS"

    echo "Finished chr$chr"
done
EOF

# Make executable and run
chmod +x run_imputation_autosomes.sh

./run_imputation_autosomes.sh

# Exit Docker
exit + Enter

# =====================================================
# 9. POST-IMPUTATION QC
# =====================================================

for chr in {1..22}; do
  echo "Filtering chr${chr}..."

  bcftools view \
    -i 'INFO/R2>=0.8 && MAF>=0.05' \
    PGRN_AMPS_autosomes_imputed_chr${chr}.dose.vcf.gz \
    -Oz \
    -o PGRN_AMPS_autosomes_imputed_chr${chr}.filtered.vcf.gz

  bcftools index PGRN_AMPS_autosomes_imputed_chr${chr}.filtered.vcf.gz

  echo "Done chr${chr}"
done
