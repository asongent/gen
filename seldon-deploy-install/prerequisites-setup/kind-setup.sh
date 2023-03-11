#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail
set -o xtrace

# The version of seldon-core to use
#SELDON_CORE_VERSION=master
SELDON_CORE_VERSION=v1.7.0
STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"
TEMPRESOURCES=${STARTUP_DIR}/tempresources
KFSERVING_TAG=v0.4.1

SDCONFIG_FILE=${HOME}/.config/seldon/seldon-deploy/sdconfig.txt
source "${SDCONFIG_FILE}"

ENABLE_METADATA_POSTGRES=${ENABLE_METADATA_POSTGRES:-true}

cd $STARTUP_DIR

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

kind_storage_setup() {
  mkdir -p /tmp/seldon-deploy/kind || true
}

kind_setup() {
    kind delete cluster || true
    #had a problem with 1.15.6 image https://github.com/SeldonIO/seldon-core/pull/1861#issuecomment-632587125
    kind create cluster --config ./kind_config.yaml --image kindest/node:v1.17.5@sha256:ab3f9e6ec5ad8840eeb1f76c89bb7948c77bbf76bcebe1a8b59790b8ae9a283a
#    kind create cluster --config ./kind_config.yaml --image kindest/node:v1.18.8@sha256:f4bcc97a0ad6e7abaf3f643d890add7efe6ee4ab90baeb374b4f41a4c95567eb
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

create_knative() {
  cd ${STARTUP_DIR}/knative
  ./install_knative.sh
}

install_EFK_and_logger() {
  cd ${STARTUP_DIR}/efk
  (
  export TEMPRESOURCES
  ./install_efk_kind.sh
  ./eventing_for_logs_ns.sh
  )
  kubectl apply -f ${STARTUP_DIR}/efk/kibana-virtualservice.yaml
}

install_seldon_core() {
  cd $STARTUP_DIR/seldon-core
  (
  export TEMPRESOURCES
  export SELDON_CORE_VERSION
  export MULTITENANT=false
  export EXTERNAL_PROTOCOL=http
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
  ./argo-kind.sh
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

install_postgres() {
  if [ "${ENABLE_METADATA_POSTGRES}" = "true" ]; then
    echo "Installing postgres..."
    cd ${STARTUP_DIR}/postgres
    export TEMPRESOURCES
    export STARTUP_DIR
    POSTGRES_MANIFEST=kind-minimal-postgres-manifest.yaml ./install_postgres.sh
  else
    echo "Skipping postgres setup. To enable set ENABLE_METADATA_POSTGRES to true"
  fi
}

check_creds
kind_storage_setup
kind_setup
setup_tempresources
create_istio
wait_istio_ready
create_knative
install_argo
install_minio
install_EFK_and_logger
install_seldon_core
install_analytics
install_kfserving
install_postgres
configure_namespaces
