#!/usr/bin/env bash
#
# based on https://www.kubeflow.org/docs/started/k8s/kfctl-istio-dex/
#
set -o nounset
set -o errexit
set -o pipefail

echo "TEMPRESOURCES IS ${TEMPRESOURCES}"
if [ -z "${TEMPRESOURCES}" ]
then
      echo "\$TEMPRESOURCES is empty"
      exit 1
else
      echo "\$TEMPRESOURCES is ${TEMPRESOURCES}"
fi

SDCONFIG_FILE=${HOME}/.config/seldon/seldon-deploy/sdconfig.txt
source "${SDCONFIG_FILE}"
export SD_USER_EMAIL=${SD_USER_EMAIL}
export SD_PASSWORD=${SD_PASSWORD}

mkdir -p ${TEMPRESOURCES}
cd ${TEMPRESOURCES}

mkdir -p ${TEMPRESOURCES}/kubeflow
cd ${TEMPRESOURCES}/kubeflow

export CONFIG_URI=https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_istio_dex.v1.2.0.yaml

wget https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-gbc038f9_linux.tar.gz

tar -xvf kfctl_v1.2.0-0-gbc038f9_linux.tar.gz

# Add kfctl to PATH, to make the kfctl binary easier to use.
# Use only alphanumeric characters or - in the directory name.
export PATH=$PATH:"${TEMPRESOURCES}/kubeflow"

# Set KF_NAME to the name of your Kubeflow deployment. You also use this
# value as directory name when creating your configuration directory.
# For example, your deployment name can be 'my-kubeflow' or 'kf-test'.
export KF_NAME=seldon-kubeflow

mkdir -p ${TEMPRESOURCES}/kubeflow/base

# Set the path to the base directory where you want to store one or more
# Kubeflow deployments. For example, /opt.
# Then set the Kubeflow application directory for this deployment.
export BASE_DIR="${TEMPRESOURCES}/kubeflow/base"
export KF_DIR=${BASE_DIR}/${KF_NAME}

mkdir -p ${KF_DIR}
cd ${KF_DIR}

wget -O kfctl_istio_dex.yaml $CONFIG_URI
export CONFIG_FILE=${KF_DIR}/kfctl_istio_dex.yaml

kfctl build -V -f ${CONFIG_URI}
kfctl apply -V -f ${CONFIG_FILE}

kubectl rollout status -n istio-system deployment/istio-ingressgateway
kubectl patch service -n istio-system istio-ingressgateway -p '{"spec": {"type": "LoadBalancer"}}'

#patch minio secret
SD_USER_EMAIL_B64=$(echo -ne "$SD_USER_EMAIL" | base64)
SD_PASSWORD_B64=$(echo -ne "$SD_PASSWORD" | base64)

#first ensure it contains what we expect it to
kubectl patch secret mlpipeline-minio-artifact -n kubeflow --type='json' -p='[{"op" : "replace" ,"path" : "/data/accesskey" ,"value" : "bWluaW8="}]'
kubectl patch secret mlpipeline-minio-artifact -n kubeflow --type='json' -p='[{"op" : "replace" ,"path" : "/data/secretkey" ,"value" : "bWluaW8xMjM="}]'

#now replace that
kubectl get secret mlpipeline-minio-artifact -n kubeflow -o yaml > ${BASE_DIR}/minio-secret.yaml
sed -i 's/bWluaW8=/'${SD_USER_EMAIL_B64}'/g' ${BASE_DIR}/minio-secret.yaml
sed -i 's/bWluaW8xMjM=/'${SD_PASSWORD_B64}'/g' ${BASE_DIR}/minio-secret.yaml
kubectl apply -f ${BASE_DIR}/minio-secret.yaml
#and restart minio
kubectl delete pod -n kubeflow -l app=minio