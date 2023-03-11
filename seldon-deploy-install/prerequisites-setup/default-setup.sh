#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail
set -o xtrace

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

SELDON_CORE_DIR=${SELDON_CORE_DIR:-}
KFSERVING_DIR=${KFSERVING_DIR:-}

# The version of seldon-core to use
#SELDON_CORE_VERSION=master
SELDON_CORE_VERSION=v1.7.0

# The version of kfserving to use
KFSERVING_TAG=v0.4.1
ENABLE_KNATIVE_XIP=true
TEMPRESOURCES=${STARTUP_DIR}/tempresources

SDCONFIG_FILE=${HOME}/.config/seldon/seldon-deploy/sdconfig.txt
source "${SDCONFIG_FILE}"

ENABLE_METADATA_POSTGRES=${ENABLE_METADATA_POSTGRES:-true}

check_creds() {
  if (( ${#SD_USER_EMAIL} < 8 ))
  then
    echo "username must be at least 8 characters"
    exit 1
  fi

  if (( ${#SD_PASSWORD} < 8 ))
  then
    echo "password must be at least 8 characters"
    exit 1
  fi
}

setup_tempresources() {
    ${STARTUP_DIR}/clean
    mkdir -p ${TEMPRESOURCES}
}

create_istio() {
    cd ${TEMPRESOURCES}
    ${STARTUP_DIR}/istio/install_istio_new.sh
    cd ${STARTUP_DIR}
}

wait_istio_ready() {
    kubectl rollout status -n istio-system deployment.v1.apps/istio-ingressgateway
}

configure_https(){
  if [ "${EXTERNAL_PROTOCOL}" = "https" ]; then
    kubectl apply -f ${STARTUP_DIR}/istio/seldon-gateway.yaml

    external_ip=""
    while [ -z $external_ip ]; do
      echo "Waiting for end point..."
      external_ip=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
      external_ip+=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
      [ -z "$external_ip" ] && sleep 10
    done
    echo 'End point ready:' && echo $external_ip

    if [ ! -z $EXTERNAL_HOST ]; then
      #replace hostname for cert
      #TODO: does it make sense to issue a self-signed cert like this for a real domain (as opposed to a LB address)? 
      echo 'Creating certificate for:' && echo $EXTERNAL_HOST
      ${STARTUP_DIR}/istio/create-gateway-ssl-secret.sh

    else
      #replace ip for cert
      echo 'Creating certificate for IP/Host :' && echo $external_ip
      ${STARTUP_DIR}/istio/create-gateway-ssl-secret.sh
    fi
  fi
}

create_knative() {
  cd ${STARTUP_DIR}/knative
  ./install_knative.sh

  if [ "$ENABLE_KNATIVE_XIP" = true ] ; then
    # xip.io magic dns - https://knative.dev/docs/install/any-kubernetes-cluster/
    # can't use for kind or minikube
    kubectl apply --filename https://github.com/knative/serving/releases/download/v0.18.0/serving-default-domain.yaml
  fi
}

install_EFK_and_logger() {
  cd ${STARTUP_DIR}/efk
  (
  export TEMPRESOURCES
  ./install_efk.sh
  ./eventing_for_logs_ns.sh
  )
  kubectl apply -f ${STARTUP_DIR}/efk/kibana-virtualservice.yaml
}

install_seldon_core() {
  cd $STARTUP_DIR/seldon-core
  (
  export TEMPRESOURCES
  export SELDON_CORE_VERSION
  export MULTITENANT
  export EXTERNAL_PROTOCOL
  ./install_seldon_core.sh
  )
}

install_analytics() {
  cd $STARTUP_DIR/prometheus
  ./seldon-core-analytics.sh
}

install_kfserving() {
  cd $STARTUP_DIR/kfserving
  (
  export TEMPRESOURCES
  export KFSERVING_TAG
  ./install_kfserving.sh
  )
}

install_argo() {
  cd ${STARTUP_DIR}/argo
  ./argo.sh
}

install_minio() {
  cd ${STARTUP_DIR}/minio
  (
  export TEMPRESOURCES
  export SD_USER_EMAIL
  export SD_PASSWORD
  export STARTUP_DIR
  ./minio.sh
  )
}

configure_namespaces() {
    #set namespaces to be visible to deploy
    #also done during gitops setup but gitops is optional
    kubectl create namespace seldon || echo "namespace seldon exists"
    kubectl label ns seldon seldon.restricted=false --overwrite=true
    kubectl label ns seldon serving.kubeflow.org/inferenceservice=enabled --overwrite=true || true

    cd ${STARTUP_DIR}/configure-batch-on-ns
    (
    export TEMPRESOURCES
    export SD_USER_EMAIL
    export SD_PASSWORD
    export STARTUP_DIR
    ./batch-sa-for-ns.sh
    )
}

install_keycloak_auth() {
  cd ${STARTUP_DIR}/keycloak
  ./install_keycloak.sh
}

apply_seldon_core_auth() {
  cd ${STARTUP_DIR}/istio
  ./seldon-core-auth.sh
}

install_postgres() {
  if [ "${ENABLE_METADATA_POSTGRES}" = "true" ]; then
    echo "Installing postgres..."
    cd ${STARTUP_DIR}/postgres
    export TEMPRESOURCES
    export STARTUP_DIR
    POSTGRES_MANIFEST=minimal-postgres-manifest.yaml ./install_postgres.sh
  else
    echo "Skipping postgres setup. To enable set ENABLE_METADATA_POSTGRES to true"
  fi
}

check_creds
setup_tempresources
create_istio
wait_istio_ready
configure_https
create_knative
install_argo
install_minio
install_EFK_and_logger
install_seldon_core
install_analytics
install_kfserving
configure_namespaces
install_postgres
install_keycloak_auth
# apply_seldon_core_auth
