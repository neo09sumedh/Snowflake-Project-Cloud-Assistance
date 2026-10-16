/* 
Lab 7: Add Unstructured Knowledge with Cortex Search

Let's make Lab 7 very hands-on. In Lab 6 your CLOUD_PROJECT_ASSISTANT could answer structured-data questions through Cortex Analyst. Now we'll teach it to search documents and architecture guidance.

Snowflake documents Cortex Search as a managed hybrid vector + keyword search capability for RAG and enterprise search, and specifically supports using Cortex Search as a retrieval layer for Cortex Agents.

What we're building

                   CLOUD_PROJECT_ASSISTANT
                           │
                 ┌─────────┴──────────┐
                 │                    │
                 ▼                    ▼
          Cortex Analyst        Cortex Search
                 │                    │
                 ▼                    ▼
        Semantic View      Architecture Documents
                 │
                 ▼
         Structured Data
*/

USE ROLE PROJECT_ADMIN_ROLE;
USE WAREHOUSE SUMEDH_LAB_WH;
USE DATABASE SUMEDH_LAB_DB;
USE SCHEMA PROJECT_AI;

CREATE OR REPLACE TABLE ARCHITECTURE_DOCUMENTS
(
    DOCUMENT_ID       NUMBER,
    DOCUMENT_TITLE    VARCHAR,
    DOCUMENT_CATEGORY VARCHAR,
    CLOUD_PLATFORM    VARCHAR,
    DOCUMENT_TEXT     VARCHAR,
    LAST_UPDATED      DATE
);

INSERT INTO ARCHITECTURE_DOCUMENTS
VALUES

(
    1,
    'Cloud Encryption Standard',
    'Security',
    'ALL',
    'All lab cloud workloads should use encryption for data at rest and data in transit. Encryption keys should be managed through the native cloud key management capability appropriate to the lab environment.',
    '2026-01-15'
),

(
    2,
    'OCI Database Architecture Guideline',
    'Database',
    'OCI',
    'Oracle database workloads in this lab should use OCI database services when Oracle-specific capabilities are required. High availability and disaster recovery requirements should be evaluated as part of the architecture design.',
    '2026-02-10'
),

(
    3,
    'AWS Architecture Guideline',
    'Cloud',
    'AWS',
    'AWS workloads in this lab should use approved network patterns. Applications should use private connectivity where appropriate and unnecessary public exposure should be avoided.',
    '2026-03-05'
),

(
    4,
    'Cloud Cost Management Guideline',
    'FinOps',
    'ALL',
    'Project teams in this lab should monitor compute, storage and network costs. Development compute should be suspended when it is not required to reduce unnecessary consumption.',
    '2026-04-01'
);

SELECT *
FROM ARCHITECTURE_DOCUMENTS
ORDER BY DOCUMENT_ID;

/* Assign needful permession for allowing Cortex search service to your role */

GRANT CREATE CORTEX SEARCH SERVICE
ON SCHEMA SUMEDH_LAB_DB.PROJECT_AI
TO ROLE PROJECT_ADMIN_ROLE;

/* Create Cortex Search Service */

CREATE OR REPLACE CORTEX SEARCH SERVICE
    ARCHITECTURE_SEARCH_SERVICE

ON DOCUMENT_TEXT

ATTRIBUTES
    DOCUMENT_TITLE,
    DOCUMENT_CATEGORY,
    CLOUD_PLATFORM

WAREHOUSE = SUMEDH_LAB_WH

TARGET_LAG = '1 hour'

AS

SELECT
    DOCUMENT_ID,
    DOCUMENT_TITLE,
    DOCUMENT_CATEGORY,
    CLOUD_PLATFORM,
    DOCUMENT_TEXT,
    LAST_UPDATED
FROM ARCHITECTURE_DOCUMENTS;

/* 
ARCHITECTURE_DOCUMENTS
           │
           │
           ▼
     DOCUMENT_TEXT
           │
           ▼
┌──────────────────────────┐
│ Cortex Search Service    │
│                          │
│ Hybrid search over text  │
└──────────────────────────┘
           │
           ▼
   Searchable knowledge

*/



/* 
Add Cortex Search to your Agent
AI & ML --> Agent Studio --> ValidateProjectCost-->Configuration-->Tool-->Add Search Service

With this now below would be the outcome

               ValidateProjectCost (Agent)
                         │
                "What is being asked?"
                         │
             ┌───────────┴───────────┐
             │                       │
             ▼                       ▼

      Project Data?           Architecture Guidance?
             │                       │
             ▼                       ▼

      Cortex Analyst           Cortex Search
             │                       │
             ▼                       ▼

     Semantic View        ARCHITECTURE_SEARCH_SERVICE
*/

/* Test this Queries

Q1 : Which cloud has the highest spend?

Genrated Query by Agent 
SELECT *
FROM SEMANTIC_VIEW(
    SUMEDH_LAB_DB.PROJECT_AI.PROJECT_ANALYTICS_SV
    DIMENSIONS cloud_provider
    METRICS total_cloud_cost
)
ORDER BY total_cloud_cost DESC NULLS LAST;

Genrated response
Cloud provider	Total spend	Share
Oracle Cloud Infrastructure	$74,400.00	60.27%
Amazon Web Services	$43,400.00	35.16%
Microsoft Azure	$5,650.00	4.58%



Q2 : What does the lab standard say about encryption?

I'll look for a "lab standard" document in your workspace and catalog.

Read 1 file, ran 2 commands, and ran 1 query



The standard is document 1 in your Lab 7 setup. I'll query the search service to confirm it returns it.

*********Response ************

The Cloud Encryption Standard (Security category, applies to all clouds, last updated 2026-01-15) says:

All lab cloud workloads should use encryption for data at rest and data in transit. Encryption keys should be managed through the native cloud key management capability appropriate to the lab environment.

In short:

What must be encrypted: data at rest and data in transit.
How keys are managed: with each cloud's own key management service.


*******Genrated SQL ****

SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'SUMEDH_LAB_DB.PROJECT_AI.ARCHITECTURE_SEARCH_SERVICE',
    '{"query":"lab standard encryption",
      "columns":["DOCUMENT_TITLE","DOCUMENT_CATEGORY","CLOUD_PLATFORM","DOCUMENT_TEXT","LAST_UPDATED"],
      "limit":2}'
  )
):results AS results;
*/

/* If you feel to add the PDF as Cortex search below would be the architecture 

PDF
 │
 ▼
Snowflake Stage
 │
 ▼
Parse / Extract
 │
 ▼
Text
 │
 ▼
Possibly chunk text
 │
 ▼
Table
 │
 ▼
Cortex Search

*/

