kubectl create configmap -n seldon-system model-usage-rules --from-file=model-usage.rules.yml --dry-run=client -o yaml | kubectl apply -f -

#if an existing prom delete the deployment otherwise there's a fight for the volume
kubectl delete deployment -n seldon-system seldon-core-analytics-prometheus-seldon || true

helm upgrade --install seldon-core-analytics ./../tempresources/seldon-core/helm-charts/seldon-core-analytics/  --namespace seldon-system -f ./../resources/analytics-values.yaml
