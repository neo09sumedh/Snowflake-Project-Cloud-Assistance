/* Connect Streamlit to Your Cortex Agent
User
 │
 ▼
Streamlit Chat
 │
 ▼
ValidateProjectCost (Agent)
 │
 ├──── Cortex Analyst ─── PROJECT_ANALYTICS_SV
 │
 └──── Cortex Search ──── ARCHITECTURE_SEARCH_SERVICE


*/

USE ROLE PROJECT_ADMIN_ROLE;
USE DATABASE SUMEDH_LAB_DB;
USE SCHEMA PROJECT_AI;
USE WAREHOUSE SUMEDH_LAB_WH;

SHOW AGENTS
IN SCHEMA SUMEDH_LAB_DB.PROJECT_AI;

/* 

Replace below code for streamlite , This code will connect with existing Agent and provde you the dashboard. 
import json
import streamlit as st


# ============================================================
# CONFIGURATION
# ============================================================

DATABASE = "SUMEDH_LAB_DB"
SCHEMA = "PROJECT_AI"

AGENT_NAME = "VALIDATEPROJECTCOST"

FULL_AGENT_NAME = (
    f"{DATABASE}.{SCHEMA}.{AGENT_NAME}"
)


# ============================================================
# STREAMLIT PAGE
# ============================================================

st.set_page_config(
    page_title="Cloud Project AI Assistant",
    page_icon="☁️",
    layout="wide"
)

st.title("☁️ Cloud Project AI Assistant")

st.caption(
    "Explore cloud projects, costs, ownership "
    "and architecture guidance using Snowflake Cortex."
)


# ============================================================
# SNOWFLAKE CONNECTION
# ============================================================

try:

    conn = st.connection("snowflake")

    session = conn.session()

except Exception as e:

    st.error(
        f"Unable to connect to Snowflake: {e}"
    )

    st.stop()


# ============================================================
# SESSION STATE
# ============================================================

if "messages" not in st.session_state:

    st.session_state.messages = []


# ============================================================
# HELPER: EXTRACT AGENT RESPONSE
# ============================================================

def extract_agent_text(response_json):

    if response_json is None:
        return "No response was returned by the Agent."

    # DATA_AGENT_RUN returns JSON as a string
    if isinstance(response_json, str):

        try:
            response_json = json.loads(response_json)
        except Exception:
            return response_json

    if isinstance(response_json, dict):

        content = response_json.get("content", [])

        text_parts = []

        if isinstance(content, list):

            for item in content:

                if not isinstance(item, dict):
                    continue

                # We only want final text blocks
                if item.get("type") == "text":

                    text = item.get("text")

                    if text:
                        text_parts.append(text)

        if text_parts:
            return "\n\n".join(text_parts)

    # Debug fallback
    return json.dumps(
        response_json,
        indent=2,
        default=str
    )
# ============================================================
# HELPER: CALL CORTEX AGENT
# ============================================================

import json


def sql_string_literal(value):
    """
    Converts a Python string into a safe Snowflake SQL string literal.
    """
    return "'" + str(value).replace("'", "''") + "'"


def ask_agent(question):
    """
    Sends one user question to an existing Snowflake Cortex Agent.
    """

    if not question or not question.strip():
        return "Please enter a question.", None

    # FULL_AGENT_NAME must be:
    # DATABASE_NAME.SCHEMA_NAME.AGENT_NAME
    agent_literal = sql_string_literal(FULL_AGENT_NAME)

    request_body = {
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": question.strip()
                    }
                ]
            }
        ],
        "stream": False
    }

    request_json = json.dumps(request_body)
    request_literal = sql_string_literal(request_json)

    # Both values are inserted as SQL string literals.
    # Do not use PARSE_JSON for the request body.
    sql = f"""
        SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
            {agent_literal},
            {request_literal}
        ) AS RESPONSE
    """

    try:
        result = session.sql(sql).collect()

        if not result:
            return "The Cortex Agent returned no result.", None

        raw_response = result[0]["RESPONSE"]

        if isinstance(raw_response, str):
            try:
                parsed_response = json.loads(raw_response)
            except json.JSONDecodeError:
                parsed_response = raw_response
        else:
            parsed_response = raw_response

        display_text = extract_agent_text(parsed_response)

        return display_text, parsed_response

    except Exception as exc:
        return f"Cortex Agent error: {str(exc)}", None


# ============================================================
# SIDEBAR
# ============================================================

with st.sidebar:

    st.header("Cloud Project Assistant")

    st.write(
        "This application uses:"
    )

    st.markdown(
        """
        - Snowflake Cortex Agent
        - Cortex Analyst
        - Semantic View
        - Cortex Search
        - Streamlit
        """
    )

    st.divider()

    st.subheader("Try asking")

    st.markdown(
        """
        **Structured data**

        - Which cloud has the highest spend?
        - Show active projects by owner.
        - Show project cost by business unit.
        - Show monthly project spend.

        **Architecture knowledge**

        - How should cloud data be protected?
        - What guidance exists for OCI databases?
        - What does the architecture guidance say about AWS?

        **Combined**

        - Which active projects run on AWS and what architecture guidance applies?
        """
    )

    st.divider()

    if st.button(
        "Clear Conversation",
        use_container_width=True
    ):

        st.session_state.messages = []

        st.rerun()


# ============================================================
# DASHBOARD
# ============================================================

st.header("Project Overview")


# ------------------------------------------------------------
# KPI QUERY
# ------------------------------------------------------------

try:

    kpi_sql = f"""
        SELECT

            SUM(TOTAL_PROJECT_COST)
                AS TOTAL_PROJECT_COST,

            COUNT(
                DISTINCT CASE
                    WHEN PROJECT_STATUS = 'ACTIVE'
                    THEN PROJECT_NAME
                END
            ) AS ACTIVE_PROJECTS,

            COUNT(
                DISTINCT PROJECT_NAME
            ) AS TOTAL_PROJECTS

        FROM
            {DATABASE}.{SCHEMA}.VW_PROJECT_COST
    """

    kpi_df = (
        session
        .sql(kpi_sql)
        .to_pandas()
    )

    total_cost = (
        kpi_df.iloc[0][
            "TOTAL_PROJECT_COST"
        ]
    )

    active_projects = (
        kpi_df.iloc[0][
            "ACTIVE_PROJECTS"
        ]
    )

    total_projects = (
        kpi_df.iloc[0][
            "TOTAL_PROJECTS"
        ]
    )


    col1, col2, col3 = st.columns(3)


    with col1:

        st.metric(
            "Total Project Cost",
            f"${total_cost:,.2f}"
        )


    with col2:

        st.metric(
            "Active Projects",
            int(active_projects)
        )


    with col3:

        st.metric(
            "Total Projects",
            int(total_projects)
        )


except Exception as e:

    st.warning(
        f"Unable to load project KPIs: {e}"
    )


# ============================================================
# COST BY CLOUD
# ============================================================

try:

    cloud_sql = f"""
        SELECT

            CLOUD_PROVIDER,

            SUM(
                TOTAL_PROJECT_COST
            ) AS TOTAL_COST

        FROM
            {DATABASE}.{SCHEMA}.VW_PROJECT_COST

        GROUP BY
            CLOUD_PROVIDER

        ORDER BY
            TOTAL_COST DESC
    """

    cloud_df = (
        session
        .sql(cloud_sql)
        .to_pandas()
    )


    st.subheader(
        "Project Cost by Cloud Platform"
    )


    st.bar_chart(
        cloud_df,
        x="CLOUD_PROVIDER",
        y="TOTAL_COST"
    )


except Exception as e:

    st.warning(
        f"Unable to load cloud cost chart: {e}"
    )


# ============================================================
# PROJECT DETAILS
# ============================================================

st.subheader("Project Details")


try:

    project_sql = f"""
        SELECT

            PROJECT_NAME,
            PROJECT_STATUS,
            CLOUD_PROVIDER,
            OWNER_NAME,
            BUSINESS_UNIT,
            COST_MONTH,
            TOTAL_PROJECT_COST

        FROM
            {DATABASE}.{SCHEMA}.VW_PROJECT_COST

        ORDER BY
            COST_MONTH DESC,
            TOTAL_PROJECT_COST DESC
    """

    project_df = (
        session
        .sql(project_sql)
        .to_pandas()
    )


    cloud_values = sorted(
        project_df[
            "CLOUD_PROVIDER"
        ]
        .dropna()
        .unique()
        .tolist()
    )


    cloud_options = [
        "ALL"
    ] + cloud_values


    selected_cloud = st.selectbox(
        "Cloud Platform",
        cloud_options
    )


    if selected_cloud != "ALL":

        filtered_df = project_df[
            project_df[
                "CLOUD_PROVIDER"
            ] == selected_cloud
        ]

    else:

        filtered_df = project_df


    st.dataframe(
        filtered_df,
        use_container_width=True,
        hide_index=True
    )


except Exception as e:

    st.warning(
        f"Unable to load project details: {e}"
    )


# ============================================================
# AI ASSISTANT
# ============================================================

st.divider()

st.header(
    "Ask Cloud Project Assistant"
)

st.caption(
    "Ask questions about project data, "
    "project costs or architecture guidance."
)


# ============================================================
# DISPLAY CONVERSATION HISTORY
# ============================================================

for message in st.session_state.messages:

    with st.chat_message(
        message["role"]
    ):

        st.markdown(
            message["content"]
        )


# =============================================================
# CHAT INPUT
# ============================================================

question = st.chat_input(
    "Ask about projects, costs or architecture guidance..."
)


# ============================================================
# PROCESS QUESTION
# ============================================================

if question:

    # --------------------------------------------------------
    # Store user message
    # --------------------------------------------------------

    st.session_state.messages.append(
        {
            "role": "user",
            "content": question
        }
    )


    # --------------------------------------------------------
    # Display user message
    # --------------------------------------------------------

    with st.chat_message("user"):

        st.markdown(question)


    # --------------------------------------------------------
    # Call Cortex Agent
    # --------------------------------------------------------

    with st.chat_message("assistant"):

        with st.spinner(
            "Analyzing your question..."
        ):

            try:

                answer, raw_response = (
                    ask_agent(question)
                )


                st.markdown(answer)


                # --------------------------------------------
                # Debugging / learning view
                # --------------------------------------------

                with st.expander("View Agent Response Details"):

                    st.json(
                        raw_response
                    )


            except Exception as e:

                answer = (
                    "The Cortex Agent request failed."
                )

                st.error(answer)

                st.exception(e)


    # --------------------------------------------------------
    # Store assistant response
    # --------------------------------------------------------

    st.session_state.messages.append(
        {
            "role": "assistant",
            "content": answer
        }
    )


*/


/* Please see the screenshot of  StreamLite Dashboard attached in Git Link

What we learn 

Lab 1 → Snowflake environment
Lab 2 → Physical data model
Lab 3 → Horizon/Catalog metadata foundation
Lab 4 → Semantic View
Lab 5 → Cortex Analyst
Lab 6 → Cortex Agent
Lab 7 → Cortex Search / RAG
Lab 8 → Streamlit
Lab 9 → Agent + Streamlit integration
*/