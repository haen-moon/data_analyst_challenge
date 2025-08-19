/*
 =================================================================================
 DDL Script: Create Clean Tables
 =================================================================================
 Purpose:
    This script creates tables in the 'clean' schema, dropping existing tables
    if they already exist.
    Run this script to re-define the DDL structure of 'clean' tables.
 =================================================================================
*/

drop table if exists clean.clinic_group_clean;
create table clean.clinic_group_clean (
    clinic_id           TEXT PRIMARY KEY,
    clinic_group        VARCHAR(255),
    processed_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table if exists clean.clinics_with_patients_clean;
create table clean.clinics_with_patients_clean (
	patient_clinic_membership_id    SERIAL PRIMARY KEY,
    patient_id                      TEXT,
    clinic_title                    VARCHAR(255),
    clinic_id                       TEXT,
    patient_created_at_date         DATE,
    patient_deleted_at_date         DATE,
    processed_at                    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table if exists clean.modules_clean;
create table clean.modules_clean (
    module_event_id         SERIAL PRIMARY KEY,
    patient_id              TEXT,
    module_completion_date  DATE,
    number_of_modules       INTEGER,
    processed_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);