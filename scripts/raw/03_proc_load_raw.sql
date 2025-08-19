/*
=========================================================================================
Stored Procedure: load_raw(data_dir TEXT)
=========================================================================================
Purpose:
	Ingest CSV source files into the 'raw' schema (Ingestion Layer).

Actions per table:
	- TRUNCATE the target raw tables before loading new data.
    - COPY command to load data from csv files.
    - Record two metadata columns in each row:
	    * source_filename: filename without path
	    * ingested_at: automatically stamped with current timestamp

Notes:
	- Pass an ABSOLUTE path to the repository root as 'data_dir'.
	- Date fields in CSV are dd.mm.yy; they are stored as TEXT in raw
        and parsed in the clean layer.
	- This procedure logs per-table durations and a final success message.

Usage Example:
    call raw.load_raw({repository_dir});
=========================================================================================
*/

create or replace procedure raw.load_raw(data_dir TEXT)
language plpgsql
as
$$
DECLARE
	-- timers
    start_time          TIMESTAMP;
    end_time            TIMESTAMP;
    start_time_batch    TIMESTAMP;
    end_time_batch      TIMESTAMP;

    -- full paths
    p_clinic_group              TEXT := data_dir || '/datasets/assignment_data_clinic_group.csv';
    p_clinics_with_patients     TEXT := data_dir || '/datasets/assignment_data_clinics_with_patients.csv';
    p_modules                   TEXT := data_dir || '/datasets/assignment_data_modules.csv';

    -- get only file names for source_filename metadata
    f_clinic_group              TEXT := regexp_replace(p_clinic_group, '^.*[\\/]', '');
    f_clinics_patients          TEXT := regexp_replace(p_clinics_with_patients, '^.*[\\/]', '');
    f_modules                   TEXT := regexp_replace(p_modules, '^.*[\\/]', '');

    -- row counters
    row_count BIGINT;

BEGIN
    start_time_batch := NOW();
    RAISE NOTICE '=======================================';
    RAISE NOTICE 'Starting load into raw schema (Ingestion Layer) ...';
    RAISE NOTICE '=======================================';

    ------------------------------------------------------------------
    -- 1. Load clinic_group_raw
    ------------------------------------------------------------------
    start_time := NOW();
    TRUNCATE TABLE raw.clinic_group_raw;
    EXECUTE format(
            'COPY raw.clinic_group_raw (clinic_id, clinic_group)
            FROM %L WITH (FORMAT csv, HEADER true)',
            p_clinic_group
            );
    GET DIAGNOSTICS row_count = ROW_COUNT;

    UPDATE raw.clinic_group_raw
        SET source_filename = f_clinic_group;

    end_time := NOW();
    RAISE NOTICE '>> clinic_group_raw loaded % rows in % seconds',
        row_count,
        EXTRACT(EPOCH FROM end_time - start_time);

    ------------------------------------------------------------------
    -- 2. Load clinics_with_patients_raw
    ------------------------------------------------------------------
    start_time := NOW();
    TRUNCATE TABLE raw.clinics_with_patients_raw;
    EXECUTE format(
            'COPY raw.clinics_with_patients_raw (patient_id, clinic_title, clinic_id, created_at, deleted_at)
            FROM %L WITH (FORMAT csv, HEADER true)',
            p_clinics_with_patients
            );
    GET DIAGNOSTICS row_count = ROW_COUNT;

    UPDATE raw.clinics_with_patients_raw
        SET source_filename = f_clinics_patients;

    end_time := NOW();
    RAISE NOTICE '>> clinics_with_patients_raw loaded % rows in % seconds',
        row_count,
        EXTRACT(EPOCH FROM end_time - start_time);

    ------------------------------------------------------------------
    -- 3. Load modules_raw
    ------------------------------------------------------------------
    start_time := NOW();
    TRUNCATE TABLE raw.modules_raw;
    EXECUTE format(
            'COPY raw.modules_raw (patient_id, completion_date, number_of_modules)
            FROM %L WITH (FORMAT csv, HEADER true)',
            p_modules
            );
    GET DIAGNOSTICS row_count = ROW_COUNT;

    UPDATE raw.modules_raw
        SET source_filename = f_modules;

    end_time := NOW();
    RAISE NOTICE '>> modules_raw loaded % rows in % seconds',
        row_count,
        EXTRACT(EPOCH FROM end_time - start_time);

    ------------------------------------------------------------------
    -- End loading procedure
    ------------------------------------------------------------------
    end_time_batch := NOW();
    RAISE NOTICE '=======================================';
    RAISE NOTICE 'Raw ingestion completed successfully';
    RAISE NOTICE ' - Total Duration: % seconds', EXTRACT(EPOCH FROM end_time_batch - start_time_batch);
    RAISE NOTICE '=======================================';

EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE '=======================================';
    RAISE NOTICE 'ERROR occurred during loading raw schema (ingestion layer)';
    RAISE NOTICE 'Error Message: %', SQLERRM;
    RAISE NOTICE 'Error Code: %', SQLSTATE;

END;
$$;

alter procedure raw.load_raw(TEXT) owner to current_user;