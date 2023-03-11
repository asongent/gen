echo "SELDON CORE VERSION ${SELDON_CORE_VERSION}"

GATEWAY=${GATEWAY:-"istio-system/seldon-gateway"}

if [ -z "${SELDON_CORE_DIR}" ]; then
    cd ${TEMPRESOURCES}
    git clone --branch "${SELDON_CORE_VERSION}" https://github.com/seldonio/seldon-core.git
    SELDON_CORE_DIR=${TEMPRESOURCES}/seldon-core
fi
# use the startup dir first incase a relative path was given
cd ${STARTUP_DIR}
cd ${SELDON_CORE_DIR}
echo "using $(pwd)"

if [ "$MULTITENANT" = "true" ]
then
  #don't' want core to be clusterwide in multitenant
  #adding a ns will make it namespaced - just deleting here as otherwise get conflict on the crd on re-run
  #note for multitenant a re-run also means re-running gitops
  helm delete seldon-core -n seldon-system || true
  kubectl delete crd seldondeployments.machinelearning.seldon.io || true
fi
sleep 5

kubectl create namespace seldon-system || echo "namespace seldon-system exists"
if [ "${EXTERNAL_PROTOCOL}" = "http" ]; then
  kubectl apply -f ./notebooks/resources/seldon-gateway.yaml
fi
#defaultEndpoint was "http://default-broker.seldon-logs" with knative 0.11 but brokers work differently in 0.17
helm upgrade --install seldon-core ./helm-charts/seldon-core-operator/ --namespace seldon-system --set istio.enabled="true" --set istio.gateway="${GATEWAY}" --set executor.requestLogger.defaultEndpoint="http://broker-ingress.knative-eventing.svc.cluster.local/seldon-logs/default"

kubectl rollout status -n seldon-system deployment/seldon-controller-manager

sleep 5