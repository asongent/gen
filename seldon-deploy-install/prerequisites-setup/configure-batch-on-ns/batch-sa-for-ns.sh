NAMESPACE=${1:-"seldon"}
#setups up batch service account for this namespace

echo "TEMPRESOURCES IS ${TEMPRESOURCES}"
# script expects TEMPRESOURCES, SD_USER_EMAIL and SD_PASSWORD to be set

kubectl apply -n ${NAMESPACE} -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: workflow
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - "*"
- apiGroups:
  - "apps"
  resources:
  - deployments
  verbs:
  - "*"
- apiGroups:
  - ""
  resources:
  - pods/log
  verbs:
  - "*"
- apiGroups:
  - machinelearning.seldon.io
  resources:
  - "*"
  verbs:
  - "*"
EOF

kubectl create -n ${NAMESPACE} serviceaccount workflow || echo "service account workflow exists in namespace ${NAMESPACE}"

kubectl create rolebinding -n ${NAMESPACE} workflow --role=workflow --serviceaccount=${NAMESPACE}:workflow || echo "rolebinding workflow exists in namespace ${NAMESPACE}"

kubectl create secret generic -n ${NAMESPACE} seldon-job-secret --from-literal="AWS_ACCESS_KEY_ID=${SD_USER_EMAIL}" --from-literal="AWS_SECRET_ACCESS_KEY=${SD_PASSWORD}" --from-literal="AWS_ENDPOINT_URL=http://minio.minio-system.svc.cluster.local:9000" --from-literal="USE_SSL=false" --dry-run=client -o yaml | kubectl apply -f -

#also currently need object store secret in the namespace
#check whether we've got a kubeflow minio before deciding what secret to create
miniokf=$(kubectl get svc -n kubeflow minio-service -o jsonpath="{.metadata.name}" || true)

if [ -z "${miniokf}" ]
then
    kubectl create secret generic -n ${NAMESPACE} seldon-job-secret --from-literal="AWS_ACCESS_KEY_ID=${SD_USER_EMAIL}" --from-literal="AWS_SECRET_ACCESS_KEY=${SD_PASSWORD}" --from-literal="AWS_ENDPOINT_URL=http://minio.minio-system.svc.cluster.local:9000" --from-literal="USE_SSL=false" --dry-run=client -o yaml | kubectl apply -f -
    echo "configured for minio in minio-system"
else
    kubectl create secret generic -n ${NAMESPACE} seldon-job-secret --from-literal="AWS_ACCESS_KEY_ID=${SD_USER_EMAIL}" --from-literal="AWS_SECRET_ACCESS_KEY=${SD_PASSWORD}" --from-literal="AWS_ENDPOINT_URL=http://minio-service.kubeflow.svc.cluster.local:9000" --from-literal="USE_SSL=false" --dry-run=client -o yaml | kubectl apply -f -
    echo "configured for minio in kubeflow"
fi
