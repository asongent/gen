echo "TEMPRESOURCES IS ${TEMPRESOURCES}"
ELASTIC_USER=admin
ELASTIC_PASSWORD=admin
ELASTIC_HASHED_PASSWORD=$2y$12$cuLhn2kv36HftE4NJwOu1eZBqsSrq0mYuUMzJXlzzXUNK7m8eKB2m
#above can be configured but pw can't be a number
#also a bit awkward https://github.com/opendistro-for-elasticsearch/opendistro-build/issues/558
#then this on kibana https://github.com/opendistro-for-elasticsearch/opendistro-build/blob/master/helm/opendistro-es/templates/kibana/kibana-deployment.yaml#L58
#gen pw hash using https://aws.amazon.com/blogs/opensource/change-passwords-open-distro-for-elasticsearch/
#but had to remove kibana from docker-compose, exec in and chmod on the file. Also then have to set a cookie pw (can be same).
#result for 12341234 is $2y$12$cuLhn2kv36HftE4NJwOu1eZBqsSrq0mYuUMzJXlzzXUNK7m8eKB2m BUT KIBANA REJECTS IT
#gives error "[config validation of [elasticsearch].password]: expected value of type [string] but got [number]"

kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl create namespace seldon-logs || echo "namespace seldon-logs exists"
kubectl create namespace seldon-system || echo "namespace seldon-system exists"

#need secrets in seldon-logs and seldon-system namespaces as Deploy needs to speak to elastic using the secret
kubectl create secret generic elastic-credentials -n seldon-logs \
  --from-literal=username="${ELASTIC_USER}" \
  --from-literal=password="${ELASTIC_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic elastic-credentials -n seldon-system \
  --from-literal=username="${ELASTIC_USER}" \
  --from-literal=password="${ELASTIC_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply -f -

cp values-opendistro-kind.yaml ${TEMPRESOURCES}
cp fluentd-values.yaml ${TEMPRESOURCES}
cd ${TEMPRESOURCES}
git clone https://github.com/opendistro-for-elasticsearch/opendistro-build
cd opendistro-build/helm/opendistro-es/
git fetch --all --tags
git checkout tags/v1.13.2
helm package .
helm upgrade --install elasticsearch opendistro-es-1.13.2.tgz --namespace=seldon-logs --values=../../../values-opendistro-kind.yaml


helm upgrade --install fluentd fluentd-elasticsearch --version 9.6.2 --namespace=seldon-logs --values=../../../fluentd-values.yaml --repo https://kiwigrid.github.io

kubectl rollout status -n seldon-logs deployment/elasticsearch-opendistro-es-kibana