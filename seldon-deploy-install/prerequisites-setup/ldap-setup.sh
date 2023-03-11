#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail
set -o xtrace

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

TEMPRESOURCES=${STARTUP_DIR}/tempresources

setup_tempresources() {
    "${STARTUP_DIR}/clean"
    mkdir -p "${TEMPRESOURCES}"
}

setup_ldap() {
    #ldap setup based on https://www.kubeflow.org/docs/started/k8s/kfctl-existing-arrikto/
    kubectl delete -f "${STARTUP_DIR}/resources/ldap/ldap.yaml" || true
    kubectl delete pvc -n kubeflow ldap-data-ldap-0 || true

    sleep 3

    kubectl apply -f "${STARTUP_DIR}/resources/ldap/ldap.yaml"
    kubectl rollout status deployment/phpldapadmin -n kubeflow

    sleep 12

    kubectl cp "${STARTUP_DIR}/resources/ldap/ldapusers" kubeflow/ldap-0:/tmp/ldapusers

    kubectl exec -n kubeflow ldap-0 -- ldapadd -x -f /tmp/ldapusers -D 'cn=admin,dc=example,dc=com' -w admin

    kubectl get configmap dex -n auth -o jsonpath='{.data.config\.yaml}' > "${TEMPRESOURCES}/dex-config.yaml"

    cat "${TEMPRESOURCES}/dex-config.yaml" "${STARTUP_DIR}/resources/ldap/dex-config-ldap-partial.yaml" > "${TEMPRESOURCES}/dex-config-final.yaml"

    kubectl create configmap dex --from-file=config.yaml="${TEMPRESOURCES}/dex-config-final.yaml" -n auth --dry-run=client -oyaml | kubectl apply -f -

    kubectl delete pods -n auth -l app=dex

    #after restart ldap login using uid from ldapusers file works
}

setup_tempresources
setup_ldap
