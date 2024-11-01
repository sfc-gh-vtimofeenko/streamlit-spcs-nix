import streamlit as st
import mimetypes
import pandas as pd
from toolz import pipe
from snowflake.snowpark import Session, DataFrame
import snowflake.connector
import os
import uuid


uploaded_file = st.file_uploader("Choose a file")

if uploaded_file is not None:
    mime_type, _ = mimetypes.guess_type(uploaded_file.name)

    match mime_type:
        case "text/csv":
            pipe(uploaded_file, pd.read_csv, st.write)
        case "image/png":
            pipe(uploaded_file, st.image)

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
                # in SiS it would just be session = get_active_session()

                pipe("SELECT CURRENT_ACCOUNT()",
                     session.sql,
                     DataFrame.collect,
                     st.write
                     )


                # Convert image base64 string into hex
                bytes_data_in_hex = uploaded_file.getvalue().hex()

                # Generate new image file name
                file_name = 'img_' + str(uuid.uuid4())

                session.sql("USE WAREHOUSE adhoc").collect()
                session.sql("USE SCHEMA spcs.workbench").collect()

                df = pd.DataFrame({"FILE_NAME": [file_name], "IMAGE_BYTES": [bytes_data_in_hex]})
                session.write_pandas(df,
                                     table_name = "IMAGES",
                                     database = "SPCS",
                                     schema = "WORKBENCH",
                                     auto_create_table=True)
                st.info("File uploaded to table")
                predicted_label = session.sql(f"SELECT spcs.workbench.image_recognition_using_bytes(image_bytes) as PREDICTED_LABEL from spcs.workbench.images where FILE_NAME = '{file_name}'").to_pandas().iloc[0,0]

                st.code(f"Label: {predicted_label}")
            else:
                st.write("Cannot open the token?")

        case _:
            st.write(f"Detected {mime_type}")

