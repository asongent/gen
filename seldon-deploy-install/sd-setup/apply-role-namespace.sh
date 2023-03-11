#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail
set -o noclobber
set -o noglob


NAMESPACES="$1"
DEPLOYNAMESPACE=${2:-"seldon-system"}

if [ -z "${NAMESPACES}" ]
then
    NAMESPACES="default"
fi
echo "applying roles for namespaces ${NAMESPACES}"
STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo ${STARTUP_DIR}

#iterate comma-separated namespaces
for NS in $(echo $NAMESPACES | sed "s/,/ /g")
do
    echo "applying roles for namespace ${NS}"
    rm ${STARTUP_DIR}/tempresources/rbac-${NS}.yaml &> /dev/null || true
    mkdir ${STARTUP_DIR}/tempresources/ &> /dev/null || true
    sed -e "s/\${i}/1/" -e "s/\${namespace}/${NS}/" -e "s/\${deploy-namespace}/${DEPLOYNAMESPACE}/" ${STARTUP_DIR}/rbac-namespace.yaml > ${STARTUP_DIR}/tempresources/rbac-${NS}.yaml
    kubectl apply -f ${STARTUP_DIR}/tempresources/rbac-${NS}.yaml
done
echo "Created namespaced roles"