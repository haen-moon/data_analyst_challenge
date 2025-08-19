/*
========================================================================================
Stored Procedure: load_clean()
========================================================================================
Purpose:
    Perform the ETL process to populate the 'clean' schema

Actions per table:
    - TRUNCATE clean tables before loading cleaned data.
    - INSERT transformed and cleaned data from raw into clean tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    call clean.load_clean();
========================================================================================
*/
create procedure load_clean()
language plpgsql
as
$$
DECLARE
	-- timers
    start_time          TIMESTAMP;
    end_time            TIMESTAMP;
    start_time_batch    TIMESTAMP;
    end_time_batch      TIMESTAMP;

BEGIN
    start_time_batch := NOW();
    RAISE NOTICE '=======================================';
    RAISE NOTICE 'Starting load into clean schema (Processing Layer) ...';
    RAISE NOTICE '=======================================';

    ------------------------------------------------------------------
    -- 1. Load clinic_group_clean
    ------------------------------------------------------------------
    start_time := NOW();
    TRUNCATE TABLE clean.clinic_group_clean;

    insert into clean.clinic_group_clean (clinic_id, clinic_group)
    select clinic_id,

           case
               when clinic_group is null then 'Unassigned'
               else regexp_replace(initcap(regexp_replace(trim(clinic_group), '\s+', ' ', 'g')), 'Gmbh', 'GmbH',
                                   'g') end as clinic_group
    from raw.clinic_group_raw;

    end_time := NOW();
    RAISE NOTICE '>> clinic_group_clean loaded in % seconds', EXTRACT(EPOCH FROM end_time - start_time);

    ------------------------------------------------------------------
    -- 2. Load clinics_with_patients_clean
    ------------------------------------------------------------------
    start_time := NOW();
    TRUNCATE TABLE clean.clinics_with_patients_clean;

    insert into clean.clinics_with_patients_clean (patient_id, clinic_title, clinic_id, created_at, deleted_at)
    select
        nullif(trim(patient_id),'') as patient_id,
        regexp_replace(initcap(trim(clinic_title)), '\s+', ' ', 'g') as clinic_title,
        nullif(trim(clinic_id),'') as clinic_id,
        to_date(nullif(trim(created_at), ''), 'dd/mm/yyyy') as created_at,
        to_date(nullif(trim(deleted_at), ''), 'dd/mm/yyyy') as deleted_at
    from raw.clinics_with_patients_raw cp
    where nullif(trim(patient_id), '') is not null
    and nullif(trim(clinic_id), '') is not null;

    end_time := NOW();
    RAISE NOTICE '>> clinics_with_patients_clean loaded in % seconds', EXTRACT(EPOCH FROM end_time - start_time);

    ------------------------------------------------------------------
    -- 3. Load modules_clean
    ------------------------------------------------------------------
    start_time := NOW();
    TRUNCATE TABLE clean.modules_clean;

    insert into clean.modules_clean(patient_id, module_generated_date, number_of_modules)
    with cleaned_raw_cte as
        (
            select nullif(trim(patient_id), '') as patient_id,
                   to_date(nullif(trim(completion_date), ''), 'dd/mm/yyyy') as module_generated_date,
                   number_of_modules
            from raw.modules_raw
            where nullif(trim(patient_id), '') is not null
              and nullif(trim(completion_date), '') is not null
              and number_of_modules > 0
        ),
    aggregated as
        (
            select patient_id,
                   module_generated_date,
                   sum(number_of_modules) as number_of_modules
            from cleaned_raw_cte
            group by patient_id, module_generated_date
        )
    select *
    from aggregated;

    end_time := NOW();
    RAISE NOTICE '>> modules_clean loaded in % seconds', EXTRACT(EPOCH FROM end_time - start_time);

    ------------------------------------------------------------------
    -- End loading procedure
    ------------------------------------------------------------------
    end_time_batch := NOW();
    RAISE NOTICE '=======================================';
    RAISE NOTICE 'Clean loading completed successfully';
    RAISE NOTICE ' - Total Duration: % seconds', EXTRACT(EPOCH FROM end_time_batch - start_time_batch);
    RAISE NOTICE '=======================================';

EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE '=======================================';
    RAISE NOTICE 'ERROR occurred during loading clean schema (processing layer)';
    RAISE NOTICE 'Error Message: %', SQLERRM;
    RAISE NOTICE 'Error Code: %', SQLSTATE;

END;
$$;

alter procedure load_clean() owner to current_user;