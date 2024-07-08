FROM docker.io/python:3.12.4-slim-bookworm
RUN apt-get update && apt-get dist-upgrade -y
RUN pip install --upgrade pip
RUN pip install Django djangorestframework django-cors-headers gunicorn djangorestframework-simplejwt psycopg2-binary django-filter
WORKDIR /app
COPY start.sh ./start.sh

