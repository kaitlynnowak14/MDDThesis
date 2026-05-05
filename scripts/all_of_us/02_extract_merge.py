# ============================================================
# Title: All of Us Phenotype Extraction and Merging
# Dataset: All of Us (European Ancestry subset)
#
# Description:
#   - Extract condition, person, and survey data from BigQuery
#   - Process survey + conditon data
#   - Merge into final phenotype dataset
#   - Restrict to QC-passed EUR participants
#
# Output:
#   data/processed/all_of_us/all_of_us_merged.csv
#
# Notes: 
#   - Cohort predefined using All of Us Cohort Builder
#   - Data cannot be shared due to access restrictions
# =============================================================

# =====================================================
# 1. LOAD DATA (BIGQUERY)
# =====================================================

# ---- Condition Phenotype Data (code provided by All of Us) ----
import pandas
import os

# This query represents dataset "European Ancestry Dataset" for domain "condition" and was generated for All of Us Controlled Tier Dataset v8
dataset_95202759_condition_sql = """
    SELECT
        c_occurrence.person_id,
        c_occurrence.condition_start_datetime 
    FROM
        ( SELECT
            * 
        FROM
            `""" + os.environ["WORKSPACE_CDR"] + """.condition_occurrence` c_occurrence 
        WHERE
            (
                condition_concept_id IN (SELECT
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
            )  
            AND (
                c_occurrence.PERSON_ID IN (SELECT
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
                            AND  value_source_concept_id IN (903096))) criteria ) )
            )) c_occurrence"""

dataset_95202759_condition_df = pandas.read_gbq(
    dataset_95202759_condition_sql,
    dialect="standard",
    use_bqstorage_api=("BIGQUERY_STORAGE_API_ENABLED" in os.environ),
    progress_bar_type="tqdm_notebook")

dataset_95202759_condition_df.head(5)

# ---- Person Phenotype Data (code provided by All of Us) ----
# This query represents dataset "European Ancestry Dataset" for domain "person" and was generated for All of Us Controlled Tier Dataset v8
dataset_95202759_person_sql = """
    SELECT
        person.person_id,
        person.birth_datetime as date_of_birth,
        p_sex_at_birth_concept.concept_name as sex_at_birth 
    FROM
        `""" + os.environ["WORKSPACE_CDR"] + """.person` person 
    LEFT JOIN
        `""" + os.environ["WORKSPACE_CDR"] + """.concept` p_sex_at_birth_concept 
            ON person.sex_at_birth_concept_id = p_sex_at_birth_concept.concept_id  
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

dataset_95202759_person_df = pandas.read_gbq(
    dataset_95202759_person_sql,
    dialect="standard",
    use_bqstorage_api=("BIGQUERY_STORAGE_API_ENABLED" in os.environ),
    progress_bar_type="tqdm_notebook")

dataset_95202759_person_df.head(5)

# ---- Survey Phenotype Data (code provided by All of Us) ----
# This query represents dataset "European Ancestry Dataset" for domain "survey" and was generated for All of Us Controlled Tier Dataset v8
dataset_95202759_survey_sql = """
    SELECT
        answer.person_id,
        answer.question,
        answer.answer  
    FROM
        `""" + os.environ["WORKSPACE_CDR"] + """.ds_survey` answer   
    WHERE
        (
            question_concept_id IN (1585845, 1585892, 1585940, 1585952)
        )  
        AND (
            answer.PERSON_ID IN (SELECT
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
                        AND  value_source_concept_id IN (903096))) criteria ) )
        )"""

dataset_95202759_survey_df = pandas.read_gbq(
    dataset_95202759_survey_sql,
    dialect="standard",
    use_bqstorage_api=("BIGQUERY_STORAGE_API_ENABLED" in os.environ),
    progress_bar_type="tqdm_notebook")

dataset_95202759_survey_df.head(5)

# This query represents dataset "Survey Datetime" for domain "survey" and was generated for All of Us Controlled Tier Dataset v8
dataset_44278276_survey_sql = """
    SELECT
        answer.person_id,
        answer.survey_datetime  
    FROM
        `""" + os.environ["WORKSPACE_CDR"] + """.ds_survey` answer   
    WHERE
        (
            question_concept_id IN (SELECT
                DISTINCT concept_id                         
            FROM
                `""" + os.environ["WORKSPACE_CDR"] + """.cb_criteria` c                         
            JOIN
                (SELECT
                    CAST(cr.id as string) AS id                               
                FROM
                    `""" + os.environ["WORKSPACE_CDR"] + """.cb_criteria` cr                               
                WHERE
                    concept_id IN (1586134)                               
                    AND domain_id = 'SURVEY') a 
                    ON (c.path like CONCAT('%', a.id, '.%'))                         
            WHERE
                domain_id = 'SURVEY'                         
                AND type = 'PPI'                         
                AND subtype = 'QUESTION')
        )  
        AND (
            answer.PERSON_ID IN (SELECT
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
                        AND  value_source_concept_id IN (903096))) criteria ) )
        )"""

dataset_44278276_survey_df = pandas.read_gbq(
    dataset_44278276_survey_sql,
    dialect="standard",
    use_bqstorage_api=("BIGQUERY_STORAGE_API_ENABLED" in os.environ),
    progress_bar_type="tqdm_notebook")

dataset_44278276_survey_df.head(5)

# =====================================================
# 2. Merge Phenotype Datasets
# =====================================================

# ---- Load Libraries ----
import hail as hl
import pandas as pd

# ---- Load Dataframes ----
person_df = dataset_95202759_person_df
survey_df = dataset_95202759_survey_df
condition_df = dataset_95202759_condition_df
survey_df2 = dataset_44278276_survey_df

# ---- Process Primary Survey Data (survey_df) ----
# Remove duplicate survey responses and keep only most recent
survey_recent = survey_df.drop_duplicates(subset=["person_id", "question"], keep="last")

# Remove prefixes to standardize question names for pivoting
survey_recent["question"] = survey_recent["question"].str.replace(r"^.*?:\s*", "", regex=True)

# Pivot survey data from long to wide format so each participant becomes one row, with survey questions as columns
survey_pivot = survey_recent.pivot_table(
    index="person_id",
    columns="question",
    values="answer",
    aggfunc=lambda x: "; ".join(x.astype(str).unique())
).reset_index()
survey_pivot.columns.name = None

# ---- Process Secondary Survey Data (survey_df2) ----
# Convert survey datetime to proper datetime format
survey_df2["survey_datetime"] = pd.to_datetime(survey_df2["survey_datetime"], errors="coerce")

# Keep only most recent survey per participant
survey_recent2 = (
    survey_df2.sort_values("survey_datetime")
    .groupby("person_id", as_index=False)
    .last()  # keep most recent datetime
)

# Merge Primary and Secondary Survey Data 
person_survey_df = person_df.merge(survey_pivot, on="person_id", how="left")
person_survey_df = person_survey_df.merge(survey_recent2, on="person_id", how="left")

# ---- Process Conditions Data (condition_df) ----
# Keep only earliest conditon date for MDD (important for creating age of onset variable)
conditions_unique = (
    condition_df
    .sort_values("condition_start_datetime")
    .drop_duplicates("person_id")
    .loc[:, ["person_id", "condition_start_datetime"]]
)

# ---- Merge Conditon and Survey Phenotype Dataframes ----
merged_df = person_survey_df.merge(conditions_unique, on="person_id", how="left")

# ---- Clean Redundant Sex Variable ----
if 'Sex At Birth' in merged_df.columns:
    merged_df = merged_df.drop(columns=['Sex At Birth'])

# ---- Export & Save Final Merged Phenotype Dataset ----
# Set bucket for saving 
bucket = os.getenv("WORKSPACE_BUCKET")
if bucket is None:
    raise ValueError("WORKSPACE_BUCKET environment variable not found.")

# Export dataset
gcs_path = f"{bucket}/exports/all_of_us_merged_dataset.csv"
merged_df.to_csv(gcs_path, index=False)
print(f"Saved merged dataset to {gcs_path}")

# Take quick look at final dataset to check for errors
print(f"Number of participants: {len(merged_df)}")
display(merged_df.head(10))

# Check for missing condition values, as there should be none missing
missing_conditions = merged_df['condition_start_datetime'].isnull().sum()
print(f"Participants missing condition data: {missing_conditions}")

# =====================================================
# 3. Restrict Final Datasets to Those Identify as EUR Through PCA
# =====================================================

# Load Hail table containing European subject IDs
eur_ht = hl.read_table("eur_subject_ids.ht")

# make sure 's' is the key field containing IDs
print(eur_ht.describe())

# Convert merged_df IDs to string to match Hail table
merged_df['person_id'] = merged_df['person_id'].astype(str)

# Collect Hail table IDs
eur_ids = set(map(str, eur_ht.s.collect()))

# Filter merged_df to only those who have matching IDs in European ID list
merged_df = merged_df[merged_df['person_id'].isin(eur_ids)].copy()

# Confirm final number of participants
print("Number of participants after EUR/genomic QC filter:", merged_df.shape[0])

# =====================================================
# 4. 
# =====================================================


