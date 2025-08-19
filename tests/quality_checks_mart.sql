/*
=================================================================================
Quality Checks - Analytics Layer (mart schema)
=================================================================================
Purpose:
    Validate integrity, consistency, and modeling assumptions for the mart views.

It includes checks for:
    - Uniqueness in dimensions.
    - Referential integrity between facts and dimensions.
    - Fact grain & duplication risks.
    - Date-window sanity (membership vs module dates).
    - Consistency of success flag logic

Usage Notes
    - Run these scripts after creating mart views.
    - Execute the verification queries and compare the output with the expected result.
*/

-- ====================================================================
-- Checking mart.v_dim_clinic
-- ====================================================================

-- uniqueness of clinic_id
-- Expectation: no results
select clinic_id, count(*) as duplicate_count
from mart.v_dim_clinic
group by clinic_id
having count(*) >1;

-- nulls in business keys or names
-- Expectation: no results
select *
from mart.v_dim_clinic
where clinic_id is null
or trim(coalesce(clinic_title, ''))='';


-- ====================================================================
-- Checking mart.v_fact_patient_clinic_modules
-- ====================================================================

-- check for referential integrity
-- Expectation: no results
select f.*
from mart.v_fact_patient_clinic_modules f
left join mart.v_dim_clinic c on c.clinic_id=f.clinic_id
where c.clinic_id is null;

-- check if required fields exist as in expected format
-- Expectation: no result
select *
from mart.v_fact_patient_clinic_modules
where trim(coalesce(patient_id, '')) = ''
or clinic_id is null
;

-- fact granularity check
-- Expectation: no result
select patient_id, module_completion_date, count(*) as cnt
from mart.v_fact_patient_clinic_modules
group by patient_id, module_completion_date
having count(*) >1;

-- check for valid timeframe
-- Expectation: no result
select *
from mart.v_fact_patient_clinic_modules
where (module_completion_date < patient_created_at_date)
or  (patient_deleted_at_date is not null and module_completion_date > patient_deleted_at_date);

-- reconcile for total number of rows
-- Expectation: the two sum should match
with clean_version as
    (
        select sum(number_of_modules) as clean_n
        from clean.modules_clean
    ),
mart_version as
    (
        select sum(number_of_modules) as mart_n
        from mart.v_fact_patient_clinic_modules
    )
select *
from clean_version, mart_version;

-- ====================================================================
-- Checking mart.v_fact_patient_success
-- ====================================================================

-- check for one row per patient
-- Expectation: no result
select patient_id, count(*) as cnt
from mart.v_fact_patient_success
group by patient_id
having count(*)>1
;

-- no unknown patients
-- Expectation: no result
select s.*
from mart.v_fact_patient_success s
left join (select distinct patient_id from clean.clinics_with_patients_clean) p
on s.patient_id=p.patient_id
where p.patient_id is null;