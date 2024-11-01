# A sample docker file that builds this project.
#
# Pros:
# - Trivial to extend and adapt to python tooling
# Cons:
# - Non-deterministic (fixable by pinning package versions)
#

# -slim is not possible, need g++ for snowflake-connector-python
FROM python:3.10
EXPOSE 8501
WORKDIR /app
COPY src/. .

# Replace with "pip install -r requirements.txt" or use your preferred python package manager
RUN pip3 install streamlit
RUN pip3 install snowflake-connector-python
RUN pip3 install toolz
RUN pip3 install snowflake-snowpark-python

CMD ["python", "-m", "streamlit", "run", "/app/streamlit_app.py"]
