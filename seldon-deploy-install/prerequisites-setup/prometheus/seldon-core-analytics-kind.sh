kubectl create configmap -n seldon-system model-usage-rules --from-file=model-usage.rules.yml --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install seldon-core-analytics ./../tempresources/seldon-core/helm-charts/seldon-core-analytics/  --namespace seldon-system -f ./../resources/analytics-kind-values.yaml
