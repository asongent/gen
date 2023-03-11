#!/usr/bin/env bash
#
# create-user.sh
#
set -o nounset
set -o errexit
set -o pipefail
set -o noclobber
set -o noglob
#set -o xtrace

ISTIO_INGRESS=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
ISTIO_INGRESS+=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

SDCONFIG_FILE=${HOME}/.config/seldon/seldon-deploy/sdconfig.txt
source "${SDCONFIG_FILE}"
export SD_USER_EMAIL=${SD_USER_EMAIL}
export SD_PASSWORD=${SD_PASSWORD}

RESULT=$(curl -s -k --data "username=${SD_USER_EMAIL}&password=${SD_PASSWORD}&grant_type=password&client_id=admin-cli" $EXTERNAL_PROTOCOL://$ISTIO_INGRESS/auth/realms/master/protocol/openid-connect/token)
TOKEN=$(echo $RESULT | sed 's/.*access_token":"//g' | sed 's/".*//g')

echo "Creating default keycloak user"
curl -k $EXTERNAL_PROTOCOL://$ISTIO_INGRESS/auth/admin/realms/deploy-realm/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  --data '{
        "username": "seldon",
        "email": "'${SD_USER_EMAIL}'",
        "enabled":"true",
        "emailVerified": "true",
        "groups":["/data-scientist"],
        "credentials":[{
            "type":"password",
            "value":"'${SD_PASSWORD}'",
            "temporary":"false"}
            ]
        }'
echo " * Default user created"
