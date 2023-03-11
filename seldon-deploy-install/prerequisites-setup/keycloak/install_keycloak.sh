#!/usr/bin/env bash
#
# install_keycloak.sh
#
set -o nounset
set -o errexit
set -o pipefail
set -o noclobber
set -o noglob
#set -o xtrace

STARTUP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "${STARTUP_DIR}"

SDCONFIG_FILE=${HOME}/.config/seldon/seldon-deploy/sdconfig.txt
source "${SDCONFIG_FILE}"

# Create namespace if not availbale
kubectl create namespace seldon-system || true

#Install Keycloak with default realm settings
kubectl create secret generic realm-secret -n seldon-system --from-file=./realm-export.json --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install --version 8.3.0 keycloak keycloak \
  --repo=https://codecentric.github.io/helm-charts \
  --namespace=seldon-system \
  --set "keycloak.username=\"${SD_USER_EMAIL}\"" \
  --set "keycloak.password=\"${SD_PASSWORD}\"" \
  -f ./keycloak-deploy-realm.yaml

#Setup Keycloak virtual service
kubectl apply -f ./keycloak-vs.yaml

kubectl rollout status statefulsets/keycloak -n seldon-system

# Create default user
./create-user.sh
./create-api-client.sh

echo " * Keycloak setup completed"
