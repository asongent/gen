#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail
set -o noclobber
set -o noglob

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

NS="$1"
rm ./tempresources/argo-cd-namespaced-role-${NS}.yaml &> /dev/null || true
mkdir ./tempresources/ &> /dev/null || true
sed -e "s/\${i}/1/" -e "s/\${namespace}/${NS}/" ./resources/argo-cd-namespaced-role.yaml > ./tempresources/argo-cd-namespaced-role-${NS}.yaml