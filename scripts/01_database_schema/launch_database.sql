/*
=============================================================
Create Database and Schemas
=============================================================
Purpose:
    This script recreates the 'analytics_dw' database and
    launches 'bronze', 'silver', and 'gold' schemas.
Note:
    Since this project uses PostgreSQL, execute the following commands 
    individually rather than running the entire script at once. 
    (e.g. run the DROP DATABASE command first and then the CREATE DATABASE command)
WARNING:
    Running this script will permanently remove the existing
    'analytics_dw' database and all of its data
    
    Make sure you have a backup before executing this script.
    This script must be run while connected to a database other
    than 'analytics_dw', such as the default 'postgres' database.
*/

-- Drop 'analytics_dw' database if it already exists
DROP DATABASE IF EXISTS "analytics_dw";

-- Create a fresh 'analytics_dw' database
CREATE DATABASE "analytics_dw";

-- Create the Medallion Architecture schemas
CREATE SCHEMA IF NOT EXISTS bronze;

CREATE SCHEMA IF NOT EXISTS silver;

CREATE SCHEMA IF NOT EXISTS gold;
