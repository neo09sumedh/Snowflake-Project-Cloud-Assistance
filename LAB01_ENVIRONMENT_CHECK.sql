-- 1. Capture identity and role
SELECT
    CURRENT_USER()      AS USER_NAME,
    CURRENT_ROLE()      AS CURRENT_ROLE,
    CURRENT_WAREHOUSE() AS CURRENT_WAREHOUSE,
    CURRENT_ACCOUNT()   AS ACCOUNT_NAME,
    CURRENT_REGION()    AS REGION;

-- 2. Check the CoCo limit applied directly to your user
SHOW PARAMETERS LIKE 'CORTEX_CODE%' IN USER IDENTIFIER(CURRENT_USER());

-- 3. Check account-level CoCo limits, if your role permits it
SHOW PARAMETERS LIKE 'CORTEX_CODE%' IN ACCOUNT;

-- 4. Check roles assigned to you
SHOW GRANTS TO USER IDENTIFIER(CURRENT_USER());

-- 5. Check models visible in your account
SHOW MODELS IN SNOWFLAKE.MODELS;
