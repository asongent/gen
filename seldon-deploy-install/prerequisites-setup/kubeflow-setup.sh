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

# installs using https://www.kubeflow.org/docs/started/k8s/kfctl-istio-dex/
# creds admin@kubeflow.org/12341234
install_kubeflow() {
  cd $STARTUP_DIR/kubeflow
  (
  export TEMPRESOURCES
  ./kubeflow.sh
  )
}

#this gets kubeflow to add full token as header and allows deploy to find who the user is
configure_auth(){
    KF_TOKEN_HEADER=kubeflow-userid-token
    kubectl set env statefulset/authservice -n istio-system USERID_TOKEN_HEADER=$KF_TOKEN_HEADER
    kubectl patch envoyfilters.networking.istio.io -n istio-system authn-filter --type='json' -p='[{"op": "add", "path": "/spec/filters/0/filterConfig/httpService/authorizationResponse/allowedUpstreamHeaders/patterns/1", "value": {"exact":"'$KF_TOKEN_HEADER'"} }]'
}

#optionally adds https to istio if env var is set
configure_https(){
  if [ "${EXTERNAL_PROTOCOL}" = "https" ]; then
    kubectl apply -f ${STARTUP_DIR}/resources/https/Gateway.yaml

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

install_knative_eventing() {
  # kubeflow setup installs knative serving so just add eventing
  KNATIVE_EVENTING_URL=https://github.com/knative/eventing/releases/download
  EVENTING_VERSION=v0.18.3
  kubectl apply --filename ${KNATIVE_EVENTING_URL}/${EVENTING_VERSION}/eventing-crds.yaml
  kubectl apply --filename ${KNATIVE_EVENTING_URL}/${EVENTING_VERSION}/eventing-core.yaml
  kubectl apply --filename ${KNATIVE_EVENTING_URL}/${EVENTING_VERSION}/in-memory-channel.yaml
  kubectl rollout status -n knative-eventing deployment/imc-controller || true
  kubectl apply --filename ${KNATIVE_EVENTING_URL}/${EVENTING_VERSION}/mt-channel-broker.yaml
  kubectl rollout status -n knative-eventing deployment/mt-broker-controller || true
  kubectl rollout status -n knative-eventing deployment/mt-broker-filter || true

  sleep 10

}

install_EFK_and_logger() {
  cd ${STARTUP_DIR}/efk
  (
  export TEMPRESOURCES
  ./install_efk.sh
  ./eventing_for_logs_ns.sh
  )
  kubectl apply -f ${STARTUP_DIR}/efk/kibana-virtualservice-kubeflow.yaml
}

# this is optional - could use the kubeflow version of core if you want
# this replaces the kubeflow version with a named version
install_seldon_core() {
  helmname=$(kubectl get deployment -n seldon-system seldon-controller-manager -o jsonpath="{.metadata.annotations.meta\.helm\.sh/release-name}" || true)
  kubectl delete all --all-namespaces -l app.kubernetes.io/component=seldon
  kubectl delete mutatingwebhookconfigurations.admissionregistration.k8s.io seldon-mutating-webhook-configuration-kubeflow || true
  kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io seldon-validating-webhook-configuration-kubeflow || true
  if [ -z "${helmname}" ]
  then
        echo "no helm version of seldon core present"
        kubectl delete crd seldondeployments.machinelearning.seldon.io || true
  else
        echo "seldon core present via helm"
  fi
  cd $STARTUP_DIR/seldon-core
  (
  export GATEWAY="kubeflow/kubeflow-gateway"
  export TEMPRESOURCES
  export SELDON_CORE_VERSION
  ./install_seldon_core.sh
  )
}

install_analytics() {
  cd $STARTUP_DIR/prometheus
  ./seldon-core-analytics.sh
  #don't install knative monitoring
  #have analytics scrape autoscaler & activator
  kubectl annotate --overwrite -n knative-serving service autoscaler prometheus.io/scrape=true
  kubectl annotate --overwrite -n knative-serving service autoscaler prometheus.io/port=9090

  kubectl annotate --overwrite -n knative-serving service activator-service prometheus.io/scrape=true
  kubectl annotate --overwrite -n knative-serving service activator-service prometheus.io/port=9090
}

# this is optional - could use the kubeflow version of kfserving if you want
# this replaces the kubeflow version with a named version
install_kfserving() {
  kubectl delete all --all-namespaces -l app.kubernetes.io/component=kfserving
  kubectl delete mutatingwebhookconfigurations.admissionregistration.k8s.io inferenceservice.serving.kubeflow.org
  kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io inferenceservice.serving.kubeflow.org
  cd $STARTUP_DIR/kfserving
  (
  export TEMPRESOURCES
  export KFSERVING_TAG
  ./install_kfserving.sh
  kubectl patch cm -n kfserving-system inferenceservice-config -p '{"data":{"explainers":"{\n    \"alibi\":{\n        \"image\" : \"docker.io/seldonio/kfserving-alibi\",\n        \"defaultImageVersion\" : \"0.4.1\"\n    }\n}","ingress":"{\n    \"ingressGateway\" : \"kubeflow/kubeflow-gateway\",\n    \"ingressService\" : \"istio-ingressgateway.istio-system.svc.cluster.local\"\n}","logger":"{\n    \"image\" : \"gcr.io/kfserving/logger:v0.4.0\",\n    \"memoryRequest\": \"100Mi\",\n    \"memoryLimit\": \"1Gi\",\n    \"cpuRequest\": \"100m\",\n    \"cpuLimit\": \"1\",\n    \"defaultUrl\": \"http://broker-ingress.knative-eventing.svc.cluster.local/seldon-logs/default\"\n}"}}'
  )
}

configure_minio() {
  cd ${STARTUP_DIR}/minio
  kubectl apply -f miniovirtualservicekubeflow.yaml
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
    POSTGRES_MANIFEST=minimal-postgres-manifest.yaml ./install_postgres.sh
  else
    echo "Skipping postgres setup. To enable set ENABLE_METADATA_POSTGRES to true"
  fi
}
check_creds
setup_tempresources
install_kubeflow
configure_auth
configure_https
install_knative_eventing
#kubeflow has a minio - expose it externally
configure_minio
install_EFK_and_logger
install_seldon_core
install_analytics
install_kfserving
configure_namespaces
install_postgres
#kubeflow already has argo
