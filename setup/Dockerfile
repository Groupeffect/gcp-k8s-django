FROM docker.io/library/ubuntu:24.04 as base
ENV DEBIAN_FRONTEND=noninteractive
ENV HELM_FILE=helm-v3.15.2-linux-arm64.tar.gz

RUN apt-get update && apt-get install -y --no-install-recommends openssl libssl-dev wget

# RUN https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

RUN echo "ENVS:"
RUN env

FROM base as prod
WORKDIR /app
COPY app/. .
COPY helm-binary/helm /usr/local/bin/helm

CMD [ "ls -alF" ]