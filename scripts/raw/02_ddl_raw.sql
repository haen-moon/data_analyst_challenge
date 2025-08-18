/*
 =================================================================================
 DDL Script: Create Raw Tables
 =================================================================================
 Purpose:
    This script creates tables in the 'raw' schema, dropping existing tables
    if they already exist.
    Run this script to re-define the DDL structure of 'raw' tables.
 =================================================================================
*/

drop table if exists raw.clinic_group_raw;
create table raw.clinic_group_raw (
    clinic_id           TEXT,
    clinic_group        VARCHAR(255), -- nullable by source
    source_filename     VARCHAR(255),
    ingested_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table if exists raw.clinics_with_patients_raw;
create table raw.clinics_with_patients_raw (
    patient_id          TEXT,
    clinic_title        VARCHAR(255),
    clinic_id           TEXT,
    created_at          TEXT, -- dd.mm.yy in CSV; parse in clean schema
    deleted_at          TEXT, -- dd.mm.yy in CSV; parse in clean schema
    source_filename     VARCHAR(255),
    ingested_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table if exists raw.modules_raw;
create table raw.modules_raw (
    patient_id          TEXT,
    completion_date     TEXT, -- dd.mm.yy in CSV; parse in clean schema
    number_of_modules   INTEGER,
    source_filename     VARCHAR(255),
    ingested_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);