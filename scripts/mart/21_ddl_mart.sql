/*
=================================================================================
DDL Script: Create view for final dataset
=================================================================================
Purpose:
    Provide business-friendly datasets for BI (e.g., Tableau) using the clean data.
    Lightweight with view so it's always up-to-date.

Pre-requisite:
    - clean.clinic_group_clean
    - clean.clinics_with_patients_clean
    - clean.modules_clean

Usage Example:
    - These views can be queried directly for analytics and reporting
=================================================================================
*/

-- fact: patient modules per day (final dataset)
create or replace view mart.v_fact_patient_clinic_modules as
select cp.patient_id,
       cp.clinic_id,
       cp.clinic_title,
       cp.patient_created_at_date,
       cp.patient_deleted_at_date,
       cg.clinic_group,
       m.module_completion_date,
       m.number_of_modules
from clean.clinics_with_patients_clean cp
         left join clean.clinic_group_clean cg on cp.clinic_id = cg.clinic_id
         left join clean.modules_clean m on cp.patient_id = m.patient_id
;

-- dimension: clinic (business context for clinics)
create or replace view mart.v_dim_clinic as
select
    cp.clinic_id,
    max(cp.clinic_title) as clinic_title, -- pick one only (deduplication)
    cg.clinic_group as clinic_group
from clean.clinics_with_patients_clean cp
left join clean.clinic_group_clean cg on cp.clinic_id=cg.clinic_id
group by cg.clinic_group, cp.clinic_id;


-- fact: patient success flag (first date cumulative modules >= 24)
create or replace view mart.v_fact_patient_success as
with cumulative_modules as
    (
        select
            patient_id,
            module_completion_date,
            sum(number_of_modules) over (partition by patient_id order by module_completion_date) as cumulative_modules
        from clean.modules_clean
    ),
first_success_date as
    (
        select
            patient_id,
            min(module_completion_date) as first_success_date
        from cumulative_modules
        where cumulative_modules >= 24
        group by patient_id
    )
select
    cp.patient_id,
    fs.first_success_date,
    (fs.first_success_date is not null) as is_successful
from (select distinct patient_id from clean.clinics_with_patients_clean) cp
left join first_success_date fs on cp.patient_id=fs.patient_id;