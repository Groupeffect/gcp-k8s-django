#!/bin/bash
BASEDIR=$(pwd)
export NAMESPACE=backend
export APP_INSTANCE_NAME=alpha-django
export NGINX_REPLICAS=1
export DJANGO_REPLICAS=1
export DJANGO_SITE_NAME="Groupeffect"
export POSTGRES_PASSWORD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1 | tr -d '\n' | base64)"
# kubectl get storageclass

# Install the Application resource definition
# An Application resource is a collection of individual Kubernetes components, such as Services, Deployments, and so on, that you can manage as a group.
# To set up your cluster to understand Application resources, run the following command:

# You need to run this command once.
# kubectl apply -f ./application_ressources.yaml
echo apply -f $BASEDIR/application_ressources.yaml

cd /click-to-deploy/k8s/django


export DEFAULT_STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export DJANGO_DISK_SIZE="500M"
export NGINX_DISK_SIZE="500M"
export POSTGRESQL_DISK_SIZE="500M"
export NFS_PERSISTENT_DISK_SIZE="500M"
export METRICS_EXPORTER_ENABLED=false
export TAG="4.1"

export IMAGE_DJANGO="marketplace.gcr.io/google/django"
export IMAGE_DJANGO_EXPORTER="${IMAGE_DJANGO}/uwsgi-exporter:${TAG}"
export IMAGE_NGINX="${IMAGE_DJANGO}/nginx"
export IMAGE_NGINX_INIT="${IMAGE_DJANGO}/debian:${TAG}"
export IMAGE_NGINX_EXPORTER="${IMAGE_DJANGO}/nginx-exporter:${TAG}"
export IMAGE_NFS="${IMAGE_DJANGO}/nfs"
export IMAGE_POSTGRESQL="${IMAGE_DJANGO}/postgresql:${TAG}"
export IMAGE_POSTGRESQL_EXPORTER="${IMAGE_DJANGO}/postgresql-exporter:${TAG}"
export IMAGE_METRICS_EXPORTER="${IMAGE_DJANGO}/prometheus-to-sd:${TAG}"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /tmp/tls.key \
    -out /tmp/tls.crt \
    -subj "/CN=nginx/O=nginx"

export TLS_CERTIFICATE_KEY="$(cat /tmp/tls.key | base64)"
export TLS_CERTIFICATE_CRT="$(cat /tmp/tls.crt | base64)"

echo "TLS:"
echo $TLS_CERTIFICATE_KEY
echo $TLS_CERTIFICATE_CRT

# kubectl create namespace "$NAMESPACE"
echo create namespace "$NAMESPACE"

helm template "${APP_INSTANCE_NAME}" chart/django \
  --set django.image.repo="${IMAGE_DJANGO}" \
  --set django.image.tag="${TAG}" \
  --set django.replicas="${DJANGO_REPLICAS}" \
  --set django.persistence.storageClass="${DEFAULT_STORAGE_CLASS}" \
  --set django.persistence.size="${DJANGO_DISK_SIZE}" \
  --set django.site_name="${DJANGO_SITE_NAME}" \
  --set django.exporter.image="${IMAGE_DJANGO_EXPORTER}" \
  --set nginx.image.repo="${IMAGE_NGINX}" \
  --set nginx.image.tag="${TAG}" \
  --set nginx.exporter.image="${IMAGE_NGINX_EXPORTER}" \
  --set nginx.initImage="${IMAGE_NGINX_INIT}" \
  --set nginx.replicas="${NGINX_REPLICAS}" \
  --set nginx.persistence.storageClass="${DEFAULT_STORAGE_CLASS}" \
  --set nginx.persistence.size="${NGINX_DISK_SIZE}" \
  --set nginx.tls.base64EncodedPrivateKey="${TLS_CERTIFICATE_KEY}" \
  --set nginx.tls.base64EncodedCertificate="${TLS_CERTIFICATE_CRT}" \
  --set nfs.image.repo="${IMAGE_NFS}" \
  --set nfs.image.tag="${TAG}" \
  --set nfs.persistence.storageClass="${DEFAULT_STORAGE_CLASS}" \
  --set nfs.persistence.size="${NFS_PERSISTENT_DISK_SIZE}" \
  --set metrics.image="${IMAGE_METRICS_EXPORTER}" \
  --set metrics.exporter.enabled="${METRICS_EXPORTER_ENABLED}" \
  --set postgresql.image="${IMAGE_POSTGRESQL}" \
  --set postgresql.exporter.image="${IMAGE_POSTGRESQL_EXPORTER}" \
  --set postgresql.user="${DJANGO_SITE_NAME}" \
  --set postgresql.password="${POSTGRES_PASSWORD}" \
  --set postgresql.postgresDatabase="${DJANGO_SITE_NAME}" \
  --set postgresql.persistence.size="${POSTGRESQL_DISK_SIZE}" \
  > "/app/${APP_INSTANCE_NAME}_manifest.yaml"




