FROM python:3.12-slim

COPY requirements.txt /tmp/
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r /tmp/requirements.txt
