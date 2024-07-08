FROM docker.io/python:3.10
RUN apt-get update && apt-get dist-upgrade -y
WORKDIR /app
