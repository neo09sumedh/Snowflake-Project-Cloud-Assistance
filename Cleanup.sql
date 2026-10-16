-- ============================================================
-- SNOWFLAKE AI LAB CLEANUP
-- ============================================================

-- 1. Use an administrative role with the necessary ownership
USE ROLE ACCOUNTADMIN;

-- 2. Drop the complete lab database
DROP DATABASE IF EXISTS SUMEDH_LAB_DB;

-- 3. Drop dedicated lab warehouse
DROP WAREHOUSE IF EXISTS SUMEDH_LAB_WH;

-- 4. Drop custom project role
DROP ROLE IF EXISTS PROJECT_ADMIN_ROLE;