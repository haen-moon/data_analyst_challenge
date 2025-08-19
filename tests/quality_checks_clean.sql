/*
=================================================================================
Quality Checks - Processing Layer (clean schema)
=================================================================================
Purpose:
    This script performs targeted quality checks for data consistency, accuracy,
    and standardization across the 'processing layer'.

It includes checks for:
    - Null or duplicated identifiers.
    - Unwanted spaces and inconsistent casing in string fields.
    - Data standardization and consistency (e.g., title-casing, collapsed white space).
    - Invalid date range or orders.
    - Cross-table consistency

Usage Notes
    - Run these scripts after data loading to processing layer.
    - Execute the verification queries and compare the output with the expected result.
*/

-- ====================================================================
-- Checking clean.clinic_group_clean
-- ====================================================================

-- check for nulls or duplicates in primary key
-- expectation: no result
select
    clinic_id,
    count(*)
from clean.clinic_group_clean
group by clinic_id
having count(*) > 1;

-- check for nulls in clinic_group
-- expectation: no result
select *
from clean.clinic_group_clean
where clinic_group is null;

-- check for unwanted spaces
-- expectation: no results
select *
from clean.clinic_group_clean
where clinic_group != trim(clinic_group);

-- Data standardisation & consistency
-- Expectation: cleaned, standardised list of clinic_group
select distinct clinic_group
from clean.clinic_group_clean;

-- Check consistency of mapping (1 clinic -> 1 clinic_group)
-- Expectation: no result
select clinic_id, count(distinct clinic_group)
from clean.clinic_group_clean
group by clinic_id
having count(distinct clinic_group) > 1;

-- ====================================================================
-- Checking clean.clinics_with_patients_clean
-- ====================================================================

-- check if primary key exist (unique & not null)
-- Expectation: no result
select patient_clinic_membership_id, count(*)
from clean.clinics_with_patients_clean
group by patient_clinic_membership_id
having count(*) > 1;

-- check for unwanted spaces in ID fields
-- Expectation: no result
select *
from clean.clinics_with_patients_clean
where trim(coalesce(patient_id, '')) = ''
or trim(coalesce(clinic_id, '')) = '';

-- check for invalid date orders (created_at > deleted_at)
-- expectation: no result
select *
from clean.clinics_with_patients_clean
where patient_created_at_date > patient_deleted_at_date;

-- metadata stamped
-- expectation: no result
select *
from clean.clinics_with_patients_clean
where processed_at is null;

-- ====================================================================
-- Checking clean.modules_clean
-- ====================================================================

-- check if primary key exist (unique & not null)
-- Expectation: no result
select module_event_id, count(*)
from clean.modules_clean
group by module_event_id
having count(*) > 1;

-- check for unwanted spaces
-- Expectation: no result
select *
from clean.modules_clean
where trim(coalesce(patient_id, '')) =''
or module_completion_date is null;

-- check for valid count data (must be positive)
-- Expectation: no result
select *
from clean.modules_clean
where number_of_modules is null
or number_of_modules <= 0;

-- check for data granularity (one patient and module_completion_date combination)
-- Expectation: no result
select patient_id, module_completion_date, count(*) as cnt
from clean.modules_clean
group by 1, 2
having count(*) >1;

-- metadata stamped
-- Expectation: no result
select *
from clean.modules_clean
where processed_at is null;