# MDDThesis

## Overview

This repository contains analysis pipelines, quality control workflows, polygenic risk score (PRS) construction scripts, statistical analyses, and figure generation code for a Master's thesis examining genetic and socioeconomic contributions to major depressive disorder (MDD) age of onset.

Analyses were conducted in two independent datasets:

1. PGRN-AMPS
2. All of Us Research Program

The project evaluates:
- Polygenic risk scores (PRS)
- Socioeconomic status (SES)
- Sex differences
- Genetic ancestry covariates
- Associations with age of MDD onset

---

## Repository Structure

```text
MDDThesis/
├── scripts/
│   ├── pgrn_amps/
│   └── all_of_us/

## Datasets

### PGRN-AMPS

Pharmacogenomics Research Network Antidepressant Medication Pharmacogenomic Study (dbGaP).

This pipeline includes:
- Phenotype cleaning and harmonization
- Genotype quality control (PLINK)
- Liftover (GRCh37 → GRCh38)
- Imputation (SHAPEIT / MINIMAC)
- SNP overlap with PRS weights
- PRS construction (EA and MA models)
- Master dataset construction
- Regression analyses and figure generation

---

### All of Us Research Program

Controlled-access whole genome sequencing dataset analyzed in the Terra cloud environment.

This pipeline includes:
- Cohort extraction and merging
- Removal of related and flagged samples
- European ancestry filtering
- Export of PLINK files from Hail MatrixTable
- SNP overlap and PRS scoring
- Integration with phenotype data
- Statistical modeling and visualization

---

## PGRN-AMPS Pipeline (Script Order)

| Step | Script | Description |
|------|--------|-------------|
| 1 | 01_pheno_cleaning.R | Clean and filter phenotype data |
| 2 | 02_pheno_sumstats.R | Phenotype summary statistics |
| 3 | 03_id_extraction.R | Extract IDs for genotype matching |
| 4 | 04_genomic_qc.sh | Genotype QC (PLINK) |
| 5 | 05_imputation.sh | Phasing and imputation pipeline |
| 6 | 06_snp_overlap.sh | SNP overlap with PRS weights |
| 7 | 07_prs_construction.sh | PRS scoring (EA and MA) |
| 8 | 08_combining_prs.R | Combine autosomal and chrX PRS |
| 9 | 09_master_table_const.R | Construct master analytic datasets |
| 10 | 10_final_dataset.R | Final phenotype coding + SES construction |
| 11 | 11_final_analyses.R | Regression analyses |
| 12 | 12_main_figures.R | Main manuscript figures |
| 13 | 13_ses_dist_variab.R | SES distribution and variability |
| 14 | 14_supp_figures.R | Supplementary figures |

---

## All of Us Pipeline (Script Order)

| Step | Script | Description |
|------|--------|-------------|
| 1 | 01_extract_merge_pheno.py | Extract and merge phenotype data |
| 2 | 02_genomic_cohort_selection.py | Select genomic cohort |
| 3 | 03_genomic_qc.py | Genotype QC and PLINK export |
| 4 | 04_filter_eur_cohort.py | Filter to European ancestry |
| 5 | 05_snp_overlap.py | SNP overlap with PRS weights |
| 6 | 06_missing_overlap.py | Assess missing SNP overlap |
| 7 | 07_plink_prs_scoring.py | PRS scoring using PLINK |
| 8 | 08_genomic_cohort_merge.py | Merge genotype + phenotype + PRS |
| 9 | 09_final_analyses.R | Regression analyses |
| 10 | 10_phenotype_counts.R | Cohort summary statistics |
| 11 | 11_main_figures.R | Main figures |
| 12 | 12_ses_dist_variab.R | SES distribution and variability |
| 13 | 13_supp_figures.R | Supplementary figures |
| — | running_background_jobs.py | Batch execution of notebooks in Terra |

---

## Software Requirements

### R Packages
- tidyverse
- dplyr
- ggplot2
- broom
- ggeffects
- ggpattern
- tableone
- janitor

### Python Packages
- hail
- pandas
- seaborn
- bokeh

### Command Line Tools
- PLINK v1.9
- bcftools
- awk
- tabix
- SHAPEIT5
- MINIMAC4
- Docker (for phasing workflow)

---

## Data Access

Both PGRN-AMPS and All of Us datasets are controlled-access resources.

- PGRN-AMPS data accessed via dbGaP
- All of Us data accessed through Terra cloud environment

Raw genotype and phenotype data are not included in this repository and cannot be shared publicly.

---

## Genomic Processing Notes

- Genome build harmonization performed using GRCh37 → GRCh38 liftover
- PRS weights derived from trans-ancestry GWAS summary statistics (Adams et al., 2025)
- Chromosome X processed separately from autosomes in both datasets
- Related and low-quality samples removed prior to downstream analyses
- European ancestry defined using All of Us ancestry prediction pipeline

---

## Output Files

Key outputs include:

- Master analytic datasets (PGRN-AMPS + All of Us)
- PRS scores (EA and MA models)
- Regression model outputs
- Main and supplementary figures
- SES composite index (0–1 scaled)

---

## Reproducibility

All analyses were conducted using version-controlled scripts with fixed processing order.

Cloud-based analyses (All of Us) were performed within Terra workspaces.

---

## Author

Kaitlyn Nowak  
Master’s Thesis — Polygenic Risk Scores, Sex, and Socioeconomic Factors as Predictors of Age of Onset for Major Depressive Disorder
