import streamlit as st
import mimetypes
import pandas as pd
from toolz import pipe
from snowflake.snowpark import Session, DataFrame
import snowflake.connector
import os


uploaded_file = st.file_uploader("Choose a file")

if uploaded_file is not None:
    mime_type, _ = mimetypes.guess_type(uploaded_file.name)

    match mime_type:
        case "text/csv":
            pipe(uploaded_file, pd.read_csv, st.write)
        case "image/png":
            pipe(uploaded_file, st.image)
        case _:
            st.write(f"Detected {mime_type}")

# Triggers only on SPCS
# https://github.com/sfc-gh-bhess/st_spcs/blob/main/src/spcs_helpers/connection.py
if os.path.isfile("/snowflake/session/token"):
    from snowflake.snowpark import Session

    creds = {
                'host': os.getenv('SNOWFLAKE_HOST'),
                'port': os.getenv('SNOWFLAKE_PORT'),
                'protocol': "https",
                'account': os.getenv('SNOWFLAKE_ACCOUNT'),
                'authenticator': "oauth",
                'token': open('/snowflake/session/token', 'r').read(),
                'warehouse': os.getenv('SNOWFLAKE_WAREHOUSE'),
                'database': os.getenv('SNOWFLAKE_DATABASE'),
                'schema': os.getenv('SNOWFLAKE_SCHEMA'),
                'client_session_keep_alive': True
            }

    connection = snowflake.connector.connect(**creds)
    session = Session.builder.configs({"connection": connection}).create()
    pipe("SELECT CURRENT_ACCOUNT()",
         session.sql,
         DataFrame.collect)

