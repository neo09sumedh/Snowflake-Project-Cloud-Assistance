/* Building StreamLite App 

                    USER
                      │
                      ▼
              Streamlit App
                      │
                      ▼
           CLOUD_PROJECT_ASSISTANT
                Cortex Agent
                      │
          ┌───────────┴───────────┐
          ▼                       ▼
   Cortex Analyst            Cortex Search
          │                       │
          ▼                       ▼
   Semantic View         Architecture Search
          │                       │
          ▼                       ▼
 Structured data          Document knowledge


*/

USE ROLE PROJECT_ADMIN_ROLE;
USE WAREHOUSE SUMEDH_LAB_WH;
USE DATABASE SUMEDH_LAB_DB;
USE SCHEMA PROJECT_AI;

GRANT CREATE STREAMLIT
ON SCHEMA SUMEDH_LAB_DB.PROJECT_AI
TO ROLE PROJECT_ADMIN_ROLE;


/* 
Go to streamlite App under APP and select stremlite replace default code with below code and test.

import streamlit as st

st.set_page_config(
    page_title="Cloud Project AI Assistant",
    layout="wide"
)

st.title("Cloud Project AI Assistant")

conn = st.connection("snowflake")
session = conn.session()

st.success("Connected to Snowflake")


project_sql = """
SELECT
    PROJECT_NAME,
    PROJECT_STATUS,
    CLOUD_PROVIDER,
    OWNER_NAME,
    BUSINESS_UNIT,
    COST_MONTH,
    TOTAL_PROJECT_COST
FROM
    SUMEDH_LAB_DB.PROJECT_AI.VW_PROJECT_COST
ORDER BY
    COST_MONTH DESC,
    TOTAL_PROJECT_COST DESC
"""

project_df = session.sql(project_sql).to_pandas()
st.header("Project Cost Details")

st.dataframe(
    project_df,
    use_container_width=True
)

st.divider()

st.header("Ask Cloud Project Assistant")

question = st.chat_input(
    "Ask about projects, costs or architecture guidance..."
)

if question:

    with st.chat_message("user"):
        st.write(question)

    with st.chat_message("assistant"):
        st.info(
            "Cortex Agent integration will be added in Lab 9."
        )

*/
