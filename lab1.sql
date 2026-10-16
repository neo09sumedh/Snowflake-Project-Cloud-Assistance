/*=========================================================
 LAB 1 - SNOWFLAKE ENVIRONMENT SETUP
 Project: Cloud Project Analytics Assistant
=========================================================*/

----------------------------------------------------------
-- STEP 1 - CREATE ROLE
----------------------------------------------------------

USE ROLE SECURITYADMIN;

CREATE ROLE IF NOT EXISTS PROJECT_ADMIN_ROLE;

----------------------------------------------------------
-- STEP 2 - CREATE DATABASE
----------------------------------------------------------

USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS SUMEDH_LAB_DB
COMMENT = 'Snowflake AI Learning Lab Database';

----------------------------------------------------------
-- STEP 3 - GRANT DATABASE ACCESS
----------------------------------------------------------

USE ROLE SECURITYADMIN;

GRANT USAGE
ON DATABASE SUMEDH_LAB_DB
TO ROLE PROJECT_ADMIN_ROLE;

GRANT CREATE SCHEMA
ON DATABASE SUMEDH_LAB_DB
TO ROLE PROJECT_ADMIN_ROLE;

----------------------------------------------------------
-- STEP 4 - CREATE WAREHOUSE
----------------------------------------------------------

USE ROLE SYSADMIN;

CREATE WAREHOUSE IF NOT EXISTS SUMEDH_LAB_WH
WITH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
COMMENT = 'Warehouse for Snowflake AI Learning Lab';

----------------------------------------------------------
-- STEP 5 - GRANT WAREHOUSE USAGE
----------------------------------------------------------

USE ROLE SECURITYADMIN;

GRANT USAGE
ON WAREHOUSE SUMEDH_LAB_WH
TO ROLE PROJECT_ADMIN_ROLE;

GRANT OPERATE
ON WAREHOUSE SUMEDH_LAB_WH
TO ROLE PROJECT_ADMIN_ROLE;

----------------------------------------------------------
-- STEP 6 - ASSIGN ROLE TO USER
----------------------------------------------------------
-- Replace YOUR_USER_NAME with your Snowflake username

GRANT ROLE PROJECT_ADMIN_ROLE
TO USER YOUR_USER_NAME;

----------------------------------------------------------
-- STEP 7 - SWITCH TO PROJECT ROLE
----------------------------------------------------------

USE ROLE PROJECT_ADMIN_ROLE;

----------------------------------------------------------
-- STEP 8 - CREATE PROJECT SCHEMA
----------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS SUMEDH_LAB_DB.PROJECT_AI
COMMENT = 'Schema for Semantic Views, Cortex and Streamlit Labs';

----------------------------------------------------------
-- STEP 9 - GRANT SCHEMA PERMISSIONS
----------------------------------------------------------

GRANT USAGE
ON SCHEMA SUMEDH_LAB_DB.PROJECT_AI
TO ROLE PROJECT_ADMIN_ROLE;

GRANT CREATE TABLE
ON SCHEMA SUMEDH_LAB_DB.PROJECT_AI
TO ROLE PROJECT_ADMIN_ROLE;

GRANT CREATE VIEW
ON SCHEMA SUMEDH_LAB_DB.PROJECT_AI
TO ROLE PROJECT_ADMIN_ROLE;

GRANT CREATE STAGE
ON SCHEMA SUMEDH_LAB_DB.PROJECT_AI
TO ROLE PROJECT_ADMIN_ROLE;

----------------------------------------------------------
-- STEP 10 - OPTIONAL (SEMANTIC VIEWS)
----------------------------------------------------------
-- Run only if your account supports Semantic Views

GRANT CREATE SEMANTIC VIEW
ON SCHEMA SUMEDH_LAB_DB.PROJECT_AI
TO ROLE PROJECT_ADMIN_ROLE;

----------------------------------------------------------
-- STEP 11 - OPTIONAL (STREAMLIT)
----------------------------------------------------------

GRANT CREATE STREAMLIT
ON SCHEMA SUMEDH_LAB_DB.PROJECT_AI
TO ROLE PROJECT_ADMIN_ROLE;

----------------------------------------------------------
-- STEP 12 - OPTIONAL (CORTEX)
----------------------------------------------------------
-- Requires ACCOUNTADMIN or Snowflake platform admin

GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER
TO ROLE PROJECT_ADMIN_ROLE;

----------------------------------------------------------
-- STEP 13 - SET WORKING CONTEXT
----------------------------------------------------------

USE ROLE PROJECT_ADMIN_ROLE;
USE DATABASE SUMEDH_LAB_DB;
USE SCHEMA PROJECT_AI;
USE WAREHOUSE SUMEDH_LAB_WH;

----------------------------------------------------------
-- STEP 14 - VALIDATION
----------------------------------------------------------

SELECT
    CURRENT_USER()      AS USER_NAME,
    CURRENT_ROLE()      AS ROLE_NAME,
    CURRENT_DATABASE()  AS DATABASE_NAME,
    CURRENT_SCHEMA()    AS SCHEMA_NAME,
    CURRENT_WAREHOUSE() AS WAREHOUSE_NAME;