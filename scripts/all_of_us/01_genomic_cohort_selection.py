# ============================================================
# Title: Genomic Cohort Selection (All of Us Controlled Tier)
# Dataset: All of Us European Ancestry Subset (Controlled Tier v8)
#
# Description:
#   - Query genetically eligible participants for MDD thesis cohort
#   - Export final participant ID list for downstream genomic QC
#
# Output:
#   mdd_thesis_cohort.tsv (stored in WORKSPACE_BUCKET/data/)
#
# Notes:
#   - This cohort defines the genomic analysis sample
#   - Used as input for Hail QC + downstream PRS analyses
# ============================================================

# =====================================================
# 1. LOAD DATA (BIGQUERY)
# =====================================================

# ---- List of Participant IDs for Genomic Data Pull ----
from datetime import datetime
import pandas
import os

start = datetime.now()

# This query represents dataset "Genomics Pull" for domain "person" and was generated for All of Us Controlled Tier Dataset v8
dataset_97827407_person_sql = """
    SELECT
        person.person_id 
    FROM
        `""" + os.environ["WORKSPACE_CDR"] + """.person` person   
    WHERE
        person.PERSON_ID IN (SELECT
            distinct person_id  
        FROM
            `""" + os.environ["WORKSPACE_CDR"] + """.cb_search_person` cb_search_person  
        WHERE
            cb_search_person.person_id IN (SELECT
                criteria.person_id 
            FROM
                (SELECT
                    DISTINCT person_id, entry_date, concept_id 
                FROM
                    `""" + os.environ["WORKSPACE_CDR"] + """.cb_search_all_events` 
                WHERE
                    (concept_id IN(SELECT
                        DISTINCT c.concept_id 
                    FROM
                        `""" + os.environ["WORKSPACE_CDR"] + """.cb_criteria` c 
                    JOIN
                        (SELECT
                            CAST(cr.id as string) AS id       
                        FROM
                            `""" + os.environ["WORKSPACE_CDR"] + """.cb_criteria` cr       
                        WHERE
                            concept_id IN (4152280)       
                            AND full_text LIKE '%_rank1]%'      ) a 
                            ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                            OR c.path LIKE CONCAT('%.', a.id) 
                            OR c.path LIKE CONCAT(a.id, '.%') 
                            OR c.path = a.id) 
                    WHERE
                        is_standard = 1 
                        AND is_selectable = 1) 
                    AND is_standard = 1 )) criteria ) 
            AND cb_search_person.person_id IN (SELECT
                criteria.person_id 
            FROM
                (SELECT
                    DISTINCT person_id, entry_date, concept_id 
                FROM
                    `""" + os.environ["WORKSPACE_CDR"] + """.cb_search_all_events` 
                WHERE
                    (concept_id IN (1586155) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585337))) criteria ) 
            AND cb_search_person.person_id IN (SELECT
                person_id 
            FROM
                `""" + os.environ["WORKSPACE_CDR"] + """.person` p 
            WHERE
                ethnicity_concept_id IN (38003564) ) 
            AND cb_search_person.person_id IN (SELECT
                person_id 
            FROM
                `""" + os.environ["WORKSPACE_CDR"] + """.person` p 
            WHERE
                race_concept_id IN (8527) ) 
            AND cb_search_person.person_id IN (SELECT
                person_id 
            FROM
                `""" + os.environ["WORKSPACE_CDR"] + """.person` p 
            WHERE
                sex_at_birth_concept_id IN (45878463, 45880669) ) 
            AND cb_search_person.person_id IN (SELECT
                criteria.person_id 
            FROM
                (SELECT
                    DISTINCT person_id, entry_date, concept_id 
                FROM
                    `""" + os.environ["WORKSPACE_CDR"] + """.cb_search_all_events` 
                WHERE
                    (concept_id IN (1585892) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585893) 
                    OR  concept_id IN (1585892) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585894) 
                    OR  concept_id IN (1585892) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585895) 
                    OR  concept_id IN (1585892) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585896) 
                    OR  concept_id IN (1585892) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585897) 
                    OR  concept_id IN (1585892) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585898) 
                    OR  concept_id IN (1585952) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585953) 
                    OR  concept_id IN (1585952) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585955) 
                    OR  concept_id IN (1585952) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585956) 
                    OR  concept_id IN (1585952) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585954) 
                    OR  concept_id IN (1585952) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585957) 
                    OR  concept_id IN (1585952) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585958) 
                    OR  concept_id IN (1585952) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585959) 
                    OR  concept_id IN (1585952) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585960) 
                    OR  concept_id IN (1585940) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585941) 
                    OR  concept_id IN (1585940) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585942) 
                    OR  concept_id IN (1585940) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585943) 
                    OR  concept_id IN (1585940) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585944) 
                    OR  concept_id IN (1585940) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585945) 
                    OR  concept_id IN (1585940) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585946) 
                    OR  concept_id IN (1585940) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585947) 
                    OR  concept_id IN (1585940) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (1585948))) criteria ) 
            AND cb_search_person.person_id IN (SELECT
                person_id 
            FROM
                `""" + os.environ["WORKSPACE_CDR"] + """.cb_search_person` p 
            WHERE
                has_whole_genome_variant = 1 ) 
            AND cb_search_person.person_id NOT IN (SELECT
                criteria.person_id 
            FROM
                (SELECT
                    DISTINCT person_id, entry_date, concept_id 
                FROM
                    `""" + os.environ["WORKSPACE_CDR"] + """.cb_search_all_events` 
                WHERE
                    (concept_id IN(SELECT
                        DISTINCT c.concept_id 
                    FROM
                        `""" + os.environ["WORKSPACE_CDR"] + """.cb_criteria` c 
                    JOIN
                        (SELECT
                            CAST(cr.id as string) AS id       
                        FROM
                            `""" + os.environ["WORKSPACE_CDR"] + """.cb_criteria` cr       
                        WHERE
                            concept_id IN (4299535)       
                            AND full_text LIKE '%_rank1]%'      ) a 
                            ON (c.path LIKE CONCAT('%.', a.id, '.%') 
                            OR c.path LIKE CONCAT('%.', a.id) 
                            OR c.path LIKE CONCAT(a.id, '.%') 
                            OR c.path = a.id) 
                    WHERE
                        is_standard = 1 
                        AND is_selectable = 1) 
                    AND is_standard = 1 )) criteria ) 
            AND cb_search_person.person_id NOT IN (SELECT
                criteria.person_id 
            FROM
                (SELECT
                    DISTINCT person_id, entry_date, concept_id 
                FROM
                    `""" + os.environ["WORKSPACE_CDR"] + """.cb_search_all_events` 
                WHERE
                    (concept_id IN (1585940) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (903079) 
                    OR  concept_id IN (1585940) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (903096) 
                    OR  concept_id IN (1585892) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (903079) 
                    OR  concept_id IN (1585892) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (903096) 
                    OR  concept_id IN (1585952) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (903079) 
                    OR  concept_id IN (1585952) 
                    AND is_standard = 0  
                    AND  value_source_concept_id IN (903096))) criteria ) )"""

dataset_97827407_person_df = pandas.read_gbq(
    dataset_97827407_person_sql,
    dialect="standard",
    use_bqstorage_api=("BIGQUERY_STORAGE_API_ENABLED" in os.environ),
    progress_bar_type="tqdm_notebook")

dataset_97827407_person_df.head(5)

# =====================================================
# 2. Convert Pandas to TSV File & Save to Bucket
# =====================================================

# Save person IDs as strings
dataset_97827407_person_df["person_id"] = dataset_97827407_person_df["person_id"].astype(str)

# Save dataframe as tsv to workspace bucket
workspace_bucket = os.environ['WORKSPACE_BUCKET']

dataset_97827407_person_df.to_csv('mdd_thesis_cohort.tsv', index=False, sep='\t')
!gsutil cp 'mdd_thesis_cohort.tsv' {workspace_bucket}/data/
!gsutil ls {workspace_bucket}/data
