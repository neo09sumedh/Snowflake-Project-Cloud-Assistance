/* Now that we have physical Data Mart that can be understood by AI & Buisness useres , 
Lets plan for creating Horizon Context which allow adding comments ,tags and description to the physical data objects */

USE ROLE PROJECT_ADMIN_ROLE;
USE DATABASE SUMEDH_LAB_DB;
USE SCHEMA PROJECT_AI;
USE WAREHOUSE SUMEDH_LAB_WH;

/*
Without comments:AI sees technical names
With comments: AI and Catalog understand business meaning
*/

COMMENT ON TABLE DIM_CLOUD IS
'Cloud Provider Dimension containing approved enterprise cloud platforms';

COMMENT ON TABLE DIM_OWNER IS
'Business owner dimension containing ownership information';

COMMENT ON TABLE DIM_PROJECT IS
'Project Dimension containing project level attributes';

COMMENT ON TABLE FACT_PROJECT_COST IS
'Fact table containing monthly infrastructure cost for projects';

COMMENT ON VIEW VW_PROJECT_COST IS
'Business view exposing cloud project costs and ownership details';


/* Add Column Comments

Later when we create Semantic Views:
CoCo
Cortex Analyst
Streamlit

*/

COMMENT ON COLUMN DIM_PROJECT.PROJECT_ID IS
'Unique identifier of a project';

COMMENT ON COLUMN DIM_PROJECT.PROJECT_NAME IS
'Business project name';

COMMENT ON COLUMN DIM_PROJECT.CLOUD_ID IS
'Reference to cloud provider';

COMMENT ON COLUMN DIM_PROJECT.OWNER_ID IS
'Reference to project owner';

COMMENT ON COLUMN DIM_PROJECT.PROJECT_STATUS IS
'Current project lifecycle status';

COMMENT ON COLUMN DIM_PROJECT.START_DATE IS
'Project start date';

COMMENT ON COLUMN DIM_PROJECT.TARGET_GO_LIVE IS
'Planned production deployment date';

COMMENT ON COLUMN FACT_PROJECT_COST.COMPUTE_COST IS
'Monthly compute infrastructure cost';

COMMENT ON COLUMN FACT_PROJECT_COST.STORAGE_COST IS
'Monthly storage infrastructure cost';

COMMENT ON COLUMN FACT_PROJECT_COST.NETWORK_COST IS
'Monthly network infrastructure cost';

COMMENT ON COLUMN FACT_PROJECT_COST.COST_MONTH IS
'Reporting month for project costs';



/* Create Governance Tag 
Why? Tags become searchable in Horizon Catalog.
*/

CREATE OR REPLACE TAG DATA_OWNER;

CREATE OR REPLACE TAG DATA_CLASSIFICATION;

CREATE OR REPLACE TAG BUSINESS_DOMAIN;

ALTER TABLE DIM_PROJECT
SET TAG DATA_OWNER='Enterprise Architecture';

ALTER TABLE DIM_CLOUD
SET TAG DATA_OWNER='Cloud Engineering';

ALTER TABLE FACT_PROJECT_COST
SET TAG DATA_OWNER='Finance';

ALTER TABLE DIM_PROJECT
SET TAG DATA_CLASSIFICATION='Internal';

ALTER TABLE FACT_PROJECT_COST
SET TAG DATA_CLASSIFICATION='Confidential';

ALTER TABLE DIM_PROJECT
SET TAG BUSINESS_DOMAIN='Enterprise Architecture';

ALTER TABLE FACT_PROJECT_COST
SET TAG BUSINESS_DOMAIN='Cloud Financial Management';

SELECT *
FROM TABLE(
INFORMATION_SCHEMA.TAG_REFERENCES(
'DIM_PROJECT',
'TABLE'
)
);

/* Create a Curated Analytics View

This is what Horizon Catalog visualizes.
Lineage becomes:
FACT_PROJECT_COST
           |
           v
VW_PROJECT_COST
           |
           v
VW_PROJECT_ANALYTICS
*/
CREATE OR REPLACE VIEW VW_PROJECT_ANALYTICS AS
SELECT

PROJECT_NAME,
PROJECT_STATUS,
CLOUD_PROVIDER,
OWNER_NAME,
BUSINESS_UNIT,

AVG(TOTAL_PROJECT_COST) AS AVG_COST,

MAX(TOTAL_PROJECT_COST) AS MAX_COST,

SUM(TOTAL_PROJECT_COST) AS TOTAL_COST

FROM VW_PROJECT_COST

GROUP BY

PROJECT_NAME,
PROJECT_STATUS,
CLOUD_PROVIDER,
OWNER_NAME,
BUSINESS_UNIT;


/* Create Business Glossary Table

Later Semantic Views will use similar concepts. */


CREATE OR REPLACE TABLE BUSINESS_GLOSSARY (

TERM_NAME STRING,
DEFINITION STRING

);

INSERT INTO BUSINESS_GLOSSARY VALUES

('Project',
'A technology or business initiative'),

('Cloud Provider',
'Infrastructure hosting platform'),

('Active Project',
'Project currently in execution'),

('Total Project Cost',
'Compute plus Storage plus Network cost'),

('Owner',
'Team accountable for project execution');

SELECT *
FROM BUSINESS_GLOSSARY;

/*Document Key Business Metrics

Create governance metrics table.

*/

CREATE OR REPLACE TABLE BUSINESS_METRICS (

METRIC_NAME STRING,
FORMULA STRING

);

INSERT INTO BUSINESS_METRICS VALUES

(
'TOTAL_PROJECT_COST',
'COMPUTE_COST + STORAGE_COST + NETWORK_COST'
),

(
'ACTIVE_PROJECT_COUNT',
'COUNT(PROJECT_ID WHERE STATUS=ACTIVE)'
),

(
'AVERAGE_PROJECT_COST',
'AVG(TOTAL_PROJECT_COST)'
);

SHOW TABLES;
SHOW VIEWS;
SHOW TAGS;


/* 
You now have:

✅ Metadata

✅ Column descriptions

✅ Business descriptions

✅ Classification tags

✅ Ownership tags

✅ Business glossary

✅ Metric definitions

✅ Data lineage
*/