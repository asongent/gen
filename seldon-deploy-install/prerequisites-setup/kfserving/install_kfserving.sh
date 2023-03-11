echo "TEMPRESOURCES IS ${TEMPRESOURCES}"
echo "KFSERVING_TAG ${KFSERVING_TAG}"

if [ -z "${KFSERVING_DIR}" ]; then
    cd ${TEMPRESOURCES}
    git clone https://github.com/kubeflow/kfserving.git
    cd ./kfserving
    git fetch --tags
    #have to checkout commit rather than tag as v0.4.1 yaml is missing in v0.4.1 tag
    git checkout f253dd529ba25c080ca458d8dc36fd0a19bbd473
    KFSERVING_DIR=${TEMPRESOURCES}/kfserving
fi
cd ${STARTUP_DIR}
cd ${KFSERVING_DIR}
echo "using $(pwd)"

kubectl create ns kfserving-system || true

kubectl apply --validate=false -f ./install/$KFSERVING_TAG/kfserving.yaml || true
sleep 3
kubectl patch cm -n kfserving-system inferenceservice-config -p '{"data":{"explainers":"{\n    \"alibi\":{\n        \"image\" : \"docker.io/seldonio/kfserving-alibi\",\n        \"defaultImageVersion\" : \"0.4.1\"\n    }\n}","ingress":"{\n    \"ingressGateway\" : \"istio-system/seldon-gateway\",\n    \"ingressService\" : \"istio-ingressgateway.istio-system.svc.cluster.local\"\n}","logger":"{\n    \"image\" : \"gcr.io/kfserving/logger:v0.4.0\",\n    \"memoryRequest\": \"100Mi\",\n    \"memoryLimit\": \"1Gi\",\n    \"cpuRequest\": \"100m\",\n    \"cpuLimit\": \"1\",\n    \"defaultUrl\": \"http://broker-ingress.knative-eventing.svc.cluster.local/seldon-logs/default\"\n}"}}'
# Create self-signed certs because we dont have cert-manager
./hack/self-signed-ca.sh