#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail
set -o noclobber
set -o noglob

#this is for multiple namespaces
NAMESPACES="$1"
DEPLOYNAMESPACE=${2:-"seldon-system"}

echo "TEMPRESOURCES IS ${TEMPRESOURCES}"
# script expects TEMPRESOURCES, SD_USER_EMAIL and SD_PASSWORD to be set

if [ -z "${NAMESPACES}" ]
then
    NAMESPACES="default"
fi
echo "applying batch roles for namespaces ${NAMESPACES}"
STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo ${STARTUP_DIR}

#check whether we've got a kubeflow minio before deciding what secret to create
miniokf=$(kubectl get svc -n kubeflow minio-service -o jsonpath="{.metadata.name}" || true)


#iterate comma-separated namespaces
for NS in $(echo $NAMESPACES | sed "s/,/ /g")
do
    echo "applying batch roles for namespace ${NS}"
    rm ${STARTUP_DIR}/tempresources/batch-rbac-${NS}.yaml &> /dev/null || true
    mkdir ${STARTUP_DIR}/tempresources/ &> /dev/null || true
    sed -e "s/\${i}/1/" -e "s/\${namespace}/${NS}/" -e "s/\${deploy-namespace}/${DEPLOYNAMESPACE}/" ${STARTUP_DIR}/batch-rbac-namespace.yaml > ${STARTUP_DIR}/tempresources/batch-rbac-${NS}.yaml
    kubectl apply -f ${STARTUP_DIR}/tempresources/batch-rbac-${NS}.yaml
    kubectl create -n ${NS} serviceaccount workflow || echo "service account workflow exists in namespace $NS"
    kubectl create rolebinding -n ${NS} workflow --role=workflow --serviceaccount=${NS}:workflow || echo "rolebinding workflow exists in namespace $NS"

    #also currently need object store secret in the namespace
    miniokf=$(kubectl get svc -n kubeflow minio-service -o jsonpath="{.metadata.name}" || true)

    if [ -z "${miniokf}" ]
    then
        kubectl create secret generic -n ${NS} seldon-job-secret --from-literal="AWS_ACCESS_KEY_ID=${SD_USER_EMAIL}" --from-literal="AWS_SECRET_ACCESS_KEY=${SD_PASSWORD}" --from-literal="AWS_ENDPOINT_URL=http://minio.minio-system.svc.cluster.local:9000" --from-literal="USE_SSL=false" --dry-run=client -o yaml | kubectl apply -f -
        echo "configured for minio in minio-system"
    else
        kubectl create secret generic -n ${NS} seldon-job-secret --from-literal="AWS_ACCESS_KEY_ID=${SD_USER_EMAIL}" --from-literal="AWS_SECRET_ACCESS_KEY=${SD_PASSWORD}" --from-literal="AWS_ENDPOINT_URL=http://minio-service.kubeflow.svc.cluster.local:9000" --from-literal="USE_SSL=false" --dry-run=client -o yaml | kubectl apply -f -
        echo "configured for minio in kubeflow"
    fi
done

echo "Created namespaced batch roles"



