# ============================================================
# Title: Missing PRS Loci Identification (EA + MA Cohorts)
# Dataset: All of Us Controlled Tier WGS Data (GRCh38)
#
# Description:
#   - Identify PRS loci absent from overlap MatrixTables
#   - Compare PRS weight loci against overlapping MT loci
#   - Detect missing loci for downstream annotation/QC
#   - Perform analysis separately for EA and MA PRS models
#
# Output:
#   missing_EA_loci_chr7_15_X.csv
#   missing_MA_loci_chr5_7_X.csv
#
# Notes:
#   - Overlap comparison performed using locus-only matching
#   - Missing loci may reflect absent variants in genotype data
#   - Used for PRS coverage diagnostics and QC reporting
# ============================================================

# ============================================================
# 1. SET UP
# ============================================================

# ---- Import & Initialize Hail ----
import hail as hl
hl.init(default_reference='GRCh38')

# ============================================================
# 2. IDENTIFY WHICH CHROMOSOMES DID NOT OVERLAP (EA)
# ============================================================

# Chromosomes with incomplete EA overlap
missing_chrs = {"chr7", "chr15", "chrX"}

# ---- Load EA PRS Weight Loci ----
weights_loci = []

for chr_ in missing_chrs:
    w = hl.read_table(
        f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/weights_chr{chr_}.ht'
    )

    # Re-key by locus-only
    w_locus = (
        w
        .key_by()          # drop (locus, alleles)
        .key_by("locus")   # locus-only
        .select()
    )
    
    weights_loci.append(w_locus)

weights_loci = hl.Table.union(*weights_loci)
print("Total weight loci:", weights_loci.count())

# ---- Load Overlapping MT Loci ----
mt_loci = []

for chr_ in missing_chrs:
    mt_overlap = hl.read_matrix_table(
        f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MT_chr{chr_}_Overlap_locusOnly.ht'
    )
    
    mt_rows = (
        mt_overlap
        .rows()
        .key_by()
        .key_by("locus")
        .distinct()
        .select()
    )
    
    mt_loci.append(mt_rows)

mt_loci = hl.Table.union(*mt_loci)
print("Total MT loci:", mt_loci.count())

# ---- Identify Missing EA Loci ----
# Unkey tables first so we can select only the locus column
weights_small = weights_loci.key_by().select('locus')
mt_small = mt_loci.key_by().select('locus')

# Convert to Pandas
weights_pd = weights_small.to_pandas()
mt_pd = mt_small.to_pandas()

# Find missing loci
missing_loci_pd = weights_pd[~weights_pd['locus'].isin(mt_pd['locus'])]
print(missing_loci_pd)

# Export for later if needed
missing_loci_pd.to_csv(
    "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/missing_EA_loci_chr7_15_X.csv",
    index=False
)

# ============================================================
# 2. IDENTIFY WHICH CHROMOSOMES DID NOT OVERLAP (MA) (repeat same steps)
# ============================================================

# Chromosomes with incomplete MA overlap
MA_missing_chrs = {"chr5", "chr7", "chrX"}

# ---- Load MA PRS Weight Loci ----
MA_weights_loci = []

for chr_ in MA_missing_chrs:
    MA_w = hl.read_table(
        f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/weights_MA_chr{chr_}.ht'
    )

    MA_w_locus = (
        MA_w
        .key_by()        # drop old key (locus, alleles)
        .key_by("locus")
        .select()
    )

    MA_weights_loci.append(MA_w_locus)

MA_weights_loci = hl.Table.union(*MA_weights_loci)
print("Total unique MA weight loci:", MA_weights_loci.count())

# ---- Load Overlapping MT Loci ----
MA_mt_loci = []

for chr_ in MA_missing_chrs:
    MA_mt_overlap = hl.read_matrix_table(
        f'gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/MT_chr{chr_}_MA_Overlap_locusOnly.ht'
    )

    MA_mt_rows = (
        MA_mt_overlap
        .rows()
        .key_by()
        .key_by("locus")
        .distinct()
        .select()
    )

    MA_mt_loci.append(MA_mt_rows)

MA_mt_loci = hl.Table.union(*MA_mt_loci)
print("Total MA loci overlapping MT:", MA_mt_loci.count())

# ---- Identify Missing MA Loci ----
# Unkey tables first so we can select only the locus column
MA_weights_small = MA_weights_loci.key_by().select('locus')
MA_mt_small = MA_mt_loci.key_by().select('locus')

# Convert to Pandas
MA_weights_pd = MA_weights_small.to_pandas()
MA_mt_pd = MA_mt_small.to_pandas()

# Find missing loci
MA_missing_loci_pd = MA_weights_pd[~MA_weights_pd['locus'].isin(MA_mt_pd['locus'])]
print(MA_missing_loci_pd)

# Export
MA_missing_loci_pd.to_csv(
    "gs://fc-secure-6218f59e-a8a7-40a3-96cb-ee93a398ba0b/missing_MA_loci_chr5_7_X.csv",
    index=False
)
