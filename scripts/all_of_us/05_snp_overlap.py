# ============================================================
# Title: PRS Variant Overlap Extraction (Hail)
# Dataset: All of Us Controlled Tier WGS Data (GRCh38)
#
# Description:
#   - Initialize Hail environment for genomic processing
#   - Load chromosome-specific MatrixTables and PRS weight tables
#   - Identify overlapping loci between genotype data and PRS weights
#   - Save overlap MatrixTables for downstream PRS computation
#   - Summarize total overlapping loci across chromosomes
#
# Output:
#   MT_chr*_Overlap_locusOnly.ht
#   MT_chr*_MA_Overlap_locusOnly.ht
#
# Notes:
#   - Overlap performed using locus-only matching
#   - Uses chromosome-wise processing to reduce memory load
#   - Final loci count used for PRS QC validation
# ============================================================

# ============================================================
# 1. SET UP
# ============================================================

# ---- Load & Initialize Hail ----
import hail as hl
hl.init(default_reference='GRCh38')

# ---- Define Chromosomes ----
chromosomes = [f"chr{i}" for i in range(1, 23)] + ["chrX"]

# ============================================================
# 2. EA Variant Overlap
# ============================================================

# ---- Identify Overlapping PRS Variants Using Loop (EA) ----
for chr_ in chromosomes:
    out = f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MT_chr{chr_}_Overlap_locusOnly.ht'

    # Skip chromosomes if already processed
    if hl.hadoop_exists(out):
        print(f"{chr_} already done, skipping")
        continue

    print(f"Processing {chr_}")

    # Load genotype matrix
    mt = hl.read_matrix_table(
        f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MT_chr{chr_}.ht'
    )

    # Load PRS weight table
    w = hl.read_table(
        f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/weights_chr{chr_}.ht'
    )
    
    # Re-key weights by locus only instead of locus & alleles
    w = w.key_by().key_by("locus")

    # Keep only loci overlapping PRS weights
    mt_overlap = mt.semi_join_rows(w)

    # Count overlapping variants
    n_rows, n_cols = mt_overlap.count()
    print(f"{chr_}: {n_rows} overlapping variants")

    # Save overlap MatrixTable
    mt_overlap.write(out)

# ---- Count Unique Overlapping Loci (EA) ----
overlap_counts = {}
total_loci_set = set()

for chr_ in chromosomes:
    mt_overlap_path = f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MT_chr{chr_}_Overlap_locusOnly.ht'

    # Skip any missing overlap files
    if not hl.hadoop_exists(mt_overlap_path):
        print(f"{chr_} overlap file not found, skipping")
        continue

    # Load overlap MatrixTable
    mt_overlap = hl.read_matrix_table(mt_overlap_path)

    # Count unique loci within chromosome
    unique_loci = mt_overlap.rows().key_by('locus').distinct().count()
    overlap_counts[chr_] = unique_loci

    # Add loci to global set
    loci_pd = mt_overlap.rows().key_by('locus').distinct().to_pandas()
    total_loci_set.update(loci_pd['locus'])

# Print results
for chr_, n in overlap_counts.items():
    print(f"{chr_}: {n} unique overlapping loci")

print(f"Total unique loci across all chromosomes: {len(total_loci_set)}")

# ============================================================
# 3. MA Variant Overlap (exact same, but using MA files)
# ============================================================

# ---- Identify Overlapping PRS Variants Using Loop (MA) ----
for chr_ in chromosomes:
    out = f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MT_chr{chr_}_MA_Overlap_locusOnly.ht'

    if hl.hadoop_exists(out):
        print(f"{chr_} already done, skipping")
        continue

    print(f"Processing {chr_}")

    mt = hl.read_matrix_table(
        f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MT_chr{chr_}.ht'
    )

    MA_w = hl.read_table(
        f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/weights_MA_chr{chr_}.ht'
    )

    MA_w = MA_w.key_by().key_by("locus")
    
    MA_mt_overlap = mt.semi_join_rows(MA_w)

    n_rows, n_cols = MA_mt_overlap.count()
    print(f"{chr_}: {n_rows} overlapping variants")

    MA_mt_overlap.write(out)

# ---- Count Unique Overlapping Loci (MA) ----
MA_overlap_counts = {}
MA_total_loci_set = set()

for chr_ in chromosomes:
    mt_overlap_path = f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MT_chr{chr_}_MA_Overlap_locusOnly.ht'
    if not hl.hadoop_exists(mt_overlap_path):
        print(f"{chr_} overlap file not found, skipping")
        continue

    mt_overlap = hl.read_matrix_table(mt_overlap_path)

    unique_loci = mt_overlap.rows().key_by('locus').distinct().count()
    MA_overlap_counts[chr_] = unique_loci

    loci_pd = mt_overlap.rows().key_by('locus').distinct().to_pandas()
    MA_total_loci_set.update(loci_pd['locus'])

for chr_, n in MA_overlap_counts.items():
    print(f"{chr_}: {n} unique overlapping loci")

print(f"Total unique MA loci across all chromosomes: {len(MA_total_loci_set)}")
