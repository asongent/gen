echo "TEMPRESOURCES IS ${TEMPRESOURCES}"
echo "SD_USER_EMAIL IS ${SD_USER_EMAIL}"

minioVersion=8.0.8

kubectl create ns minio-system || true

helm repo add minio https://helm.min.io/ || true
helm upgrade --install minio minio/minio \
    --set accessKey=\\"${SD_USER_EMAIL}\\" \
    --set secretKey=\\"${SD_PASSWORD}\\" \
    --namespace minio-system \
    --version $minioVersion

#this allows access to minio UI
#but not minio client https://github.com/minio/minio/issues/5947
#trying gives error MinIO Client should be of the form scheme://host[:port]/ without resource component.
kubectl apply -f miniovirtualservice.yaml