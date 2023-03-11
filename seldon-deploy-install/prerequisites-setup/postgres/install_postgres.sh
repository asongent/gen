#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o noclobber
set -o noglob
#set -o xtrace

echo "Installing zalando postgres operator and a db instance if required"

cd ${TEMPRESOURCES}
git clone https://github.com/zalando/postgres-operator.git
cd postgres-operator
git checkout v1.6.2 # Use a tag to pin what we are using.
kubectl create namespace postgres || echo "namespace postgres exists"
helm upgrade --install postgres-operator ./charts/postgres-operator --namespace postgres

cd ${STARTUP_DIR}/postgres
kubectl apply -f manifests/${POSTGRES_MANIFEST}

sleep 15

cd ${TEMPRESOURCES}

for i in {1..5}
do
  postgressecret=$(kubectl get secret seldon.seldon-metadata-storage.credentials.postgresql.acid.zalan.do -n postgres -o 'jsonpath={.data.password}' || echo '')
  echo "$postgressecret" | base64 -d > db_pass
  if [ -s "db_pass" ] # If file exists AND has size > 0 we have the secret, so we can stop retrying.
  then
      echo "The postgres secret has been created by the operator..."
      break
  else
      rm -f db_pass
  fi
  echo "The postgres secret is still being created by the operator. Retrying to get it..."
  sleep 10
done

if [ ! -s "db_pass" ]
then
    echo "Could not fetch postgres password from secret seldon.seldon-metadata-storage.credentials.postgresql.acid.zalan.do in postgres namespace.
    Something has gone wrong with the postgres installation."
    exit 1
fi

kubectl create namespace seldon-system || echo "namespace seldon-system exists"
kubectl create secret generic -n seldon-system metadata-postgres \
  --from-literal=user=seldon \
  --from-file=password=./db_pass \
  --from-literal=host=seldon-metadata-storage.postgres.svc.cluster.local \
  --from-literal=port=5432 \
  --from-literal=dbname=metadata \
  --from-literal=sslmode=require \
  --dry-run=client -o yaml \
  | kubectl apply -n seldon-system -f -
rm db_pass