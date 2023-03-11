kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: default
  namespace: seldon-logs
EOF

sleep 6
broker=$(kubectl -n seldon-logs get broker default -o jsonpath='{.metadata.name}')
if [ $broker == 'default' ]; then
  echo "knative broker created"
else
  echo "knative broker not created"
  exit 1
fi
