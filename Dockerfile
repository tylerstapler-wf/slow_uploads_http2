FROM python:3
COPY server_requirements.txt /
RUN pip install -r server_requirements.txt

COPY null_fileserver.py /
CMD uvicorn null_fileserver:app --host 0.0.0.0
