/* Build the Semantic View (The Heart of Snowflake AI)


What is a Semantic View?

Currently your data looks like:

Plain Text
DIM_PROJECT
FACT_PROJECT_COST
DIM_CLOUD
DIM_OWNER

Business users don't think like that.

They think:

Plain Text
Projects
Cloud Platforms
Project Owners
Project Costs
Average Cost
Active Projects

The Semantic View translates:

Plain Text
Business Language
↓
Snowflake SQL

Snowflake semantic views define business entities, relationships, dimensions, facts, and metrics that can be used by AI and analytics tools. They provide governed business definitions over physical tables.

*/

USE ROLE PROJECT_ADMIN_ROLE;
USE DATABASE SUMEDH_LAB_DB;
USE SCHEMA PROJECT_AI;
USE WAREHOUSE SUMEDH_LAB_WH;

/* 
Semantic Architecture
              User Question

                     │

                     ▼

            Cortex Analyst

                     │

                     ▼

              Semantic View

                     │

                     ▼

             Physical Tables

                     │

                     ▼

            Snowflake Query


User Asks 
            Which cloud platform has highest project cost?

Cortex Analyst sees
            Cloud Platform
            Project Cost
Semantic View maps
            DIM_CLOUD
            FACT_PROJECT_COST
            TOTAL_PROJECT_COST


*/

/* See the code for Semantic layer in Yaml
PROJECT_ANALYTICS_SV.yaml
*/

/* Validation if semantic view gets created
Only difference is parameter TRUE is been  passed , Consider this as Dry Run
*/
CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
'SUMEDH_LAB_DB.PROJECT_AI',
$$
name: PROJECT_ANALYTICS_SV

description: Semantic View for Cloud Project Analytics

tables:

  - name: PROJECT_COST

    description: Project Cost Analytics

    base_table:

      database: SUMEDH_LAB_DB
      schema: PROJECT_AI
      table: VW_PROJECT_COST

    dimensions:

      - name: PROJECT_NAME
        description: Project Name
        expr: PROJECT_NAME
        data_type: STRING

      - name: PROJECT_STATUS
        description: Project Status
        expr: PROJECT_STATUS
        data_type: STRING

      - name: CLOUD_PROVIDER
        description: Cloud Platform
        expr: CLOUD_PROVIDER
        data_type: STRING

      - name: OWNER_NAME
        description: Business Owner
        expr: OWNER_NAME
        data_type: STRING

      - name: BUSINESS_UNIT
        description: Business Unit
        expr: BUSINESS_UNIT
        data_type: STRING

      - name: COST_MONTH
        description: Reporting Month
        expr: COST_MONTH
        data_type: DATE

    facts:

      - name: TOTAL_PROJECT_COST

        description: Total Monthly Project Cost

        expr: TOTAL_PROJECT_COST

        data_type: NUMBER

    metrics:

      - name: PROJECT_COST

        description: Sum of Project Costs

        expr: SUM(TOTAL_PROJECT_COST)

      - name: AVG_PROJECT_COST

        description: Average Project Cost

        expr: AVG(TOTAL_PROJECT_COST)

      - name: PROJECT_COUNT

        description: Number of Projects

        expr: COUNT(PROJECT_NAME)
$$,
TRUE
);

/*  Once Validated create Semantic View */

CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
'SUMEDH_LAB_DB.PROJECT_AI',
$$
name: PROJECT_ANALYTICS_SV

description: Semantic View for Cloud Project Analytics

tables:

  - name: PROJECT_COST

    description: Cloud project cost analytics

    base_table:

      database: SUMEDH_LAB_DB
      schema: PROJECT_AI
      table: VW_PROJECT_COST

    dimensions:

      - name: PROJECT_NAME

        description: Project Name

        synonyms:
          - project
          - application
          - initiative
          - solution
          - workload

        expr: PROJECT_NAME

        data_type: STRING

      - name: PROJECT_STATUS

        description: Current Project Status

        synonyms:
          - status
          - state
          - lifecycle
          - project status
          - execution status

        expr: PROJECT_STATUS

        data_type: STRING

      - name: CLOUD_PROVIDER

        description: Cloud Platform

        synonyms:
          - cloud
          - cloud provider
          - hyperscaler
          - hosting platform
          - platform
          - infrastructure provider

        expr: CLOUD_PROVIDER

        data_type: STRING

      - name: REGION

        description: Cloud Region

        synonyms:
          - location
          - datacenter
          - cloud region
          - deployment region

        expr: REGION

        data_type: STRING

      - name: OWNER_NAME

        description: Business Owner

        synonyms:
          - owner
          - project owner
          - accountable team
          - accountable organization
          - lead team
          - sponsor

        expr: OWNER_NAME

        data_type: STRING

      - name: BUSINESS_UNIT

        description: Business Unit

        synonyms:
          - organization
          - department
          - team
          - business organization
          - function

        expr: BUSINESS_UNIT

        data_type: STRING

      - name: COST_MONTH

        description: Reporting Month

        synonyms:
          - month
          - reporting period
          - cost month
          - financial month

        expr: COST_MONTH

        data_type: DATE

    facts:

      - name: TOTAL_PROJECT_COST

        description: Total Monthly Project Cost

        synonyms:
          - spend
          - expense
          - cloud spend
          - monthly spend
          - monthly cost
          - infrastructure cost
          - project expense

        expr: TOTAL_PROJECT_COST

        data_type: NUMBER

      - name: COMPUTE_COST

        description: Compute Infrastructure Cost

        synonyms:
          - compute spend
          - compute expense
          - vm cost
          - server cost

        expr: COMPUTE_COST

        data_type: NUMBER

      - name: STORAGE_COST

        description: Storage Infrastructure Cost

        synonyms:
          - storage spend
          - disk cost
          - storage expense
          - volume cost

        expr: STORAGE_COST

        data_type: NUMBER

      - name: NETWORK_COST

        description: Network Infrastructure Cost

        synonyms:
          - bandwidth cost
          - network spend
          - connectivity cost
          - network expense

        expr: NETWORK_COST

        data_type: NUMBER

    metrics:

      - name: TOTAL_CLOUD_COST

        description: Total Cloud Spend

        synonyms:
          - cloud spend
          - total spend
          - total cost
          - total expense
          - overall spend

        expr: SUM(TOTAL_PROJECT_COST)

      - name: AVG_PROJECT_COST

        description: Average Project Cost

        synonyms:
          - average spend
          - average expense
          - avg cost
          - avg spend
          - average project spend

        expr: AVG(TOTAL_PROJECT_COST)

      - name: PROJECT_COUNT

        description: Number of Projects

        synonyms:
          - count of projects
          - number of projects
          - total projects
          - project volume

        expr: COUNT(DISTINCT PROJECT_NAME)

      - name: ACTIVE_PROJECT_COUNT

        description: Number of Active Projects

        synonyms:
          - active projects
          - running projects
          - projects in progress
          - current projects

        expr: COUNT_IF(PROJECT_STATUS='ACTIVE')
$$,
FALSE
);


SHOW SEMANTIC VIEWS;


SHOW DATABASE ROLES IN DATABASE SNOWFLAKE;


SHOW SEMANTIC VIEWS;

SHOW MODELS IN SNOWFLAKE.MODELS;

SHOW GRANTS TO ROLE PROJECT_ADMIN_ROLE;

SELECT CURRENT_ACCOUNT();

USE ROLE ACCOUNTADMIN;

SHOW PARAMETERS LIKE '%CORTEX%' IN ACCOUNT;

SHOW SEMANTIC VIEWS IN SCHEMA SUMEDH_LAB_DB.PROJECT_AI;

SELECT CURRENT_REGION();

SELECT SNOWFLAKE.CORTEX.COMPLETE('llama3.1-8b', 'What is Snowflake?');