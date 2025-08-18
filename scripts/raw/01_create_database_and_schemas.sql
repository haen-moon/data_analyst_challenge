/*
================================================
Create Database and Schemas
================================================
Purpose:
    This script creates a new database called 'data_analyst_challenge'.
    It checks if the 'data_analyst_challenge' database already exist; if yes, it drop the existing database and recreate.
    Additionally, the script creates three schemas within the database

WARNING:
    Running this script will drop the entire 'data_analyst_challenge' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure proper backups before running the script.
*/

-- drop and create the database called 'data_analyst_challenge'
drop database if exists "data_analyst_challenge";
create database "data_analyst_challenge";

-- create schema
create schema if not exists raw;
create schema if not exists clean;
create schema if not exists mart;