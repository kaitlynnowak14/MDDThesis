"""
Survey_Phenotypes.py

Summary:
  Queries survey answers and survey datetimes for a specific European ancestry cohort
  in the All of Us Controlled Tier v8 dataset.

Notes: 
- This script was provided by the All of Us Research Program (Controlled Tier v8).
- This is based on a specific cohort and selected variables.
- This file includes 2 datasets:
  1. Survey Answers
  2. Survey Datetime
- If another user generates their own dataset, the SQL and results may differ.
- Do NOT modify this script - it is intented to be used as-is in the All of Us secure cloud environment.
"""

# ==============
# Survey Answers
# ==============

import pandas
import os

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

# ===============
# Survey Datetime
# ===============

import pandas
import os

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
