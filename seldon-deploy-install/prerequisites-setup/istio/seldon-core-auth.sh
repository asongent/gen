#!/bin/bash
KEYCLOAK_HOST=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
SELDON_DEPLOY_KEYCLOAK_REALM=deploy-realm
SDCONFIG_FILE=${HOME}/.config/seldon/seldon-deploy/sdconfig.txt
source "${SDCONFIG_FILE}"

kubectl apply -f - <<EOF
apiVersion: "security.istio.io/v1beta1"
kind: "RequestAuthentication"
metadata:
  name: seldon-core-requests-auth
  namespace: istio-system
spec:
  selector:
    matchLabels:
       istio: ingressgateway
  jwtRules:
  - issuer: "$EXTERNAL_PROTOCOL://$KEYCLOAK_HOST/auth/realms/master"
    jwksUri: "$EXTERNAL_PROTOCOL://$KEYCLOAK_HOST/auth/realms/master/protocol/openid-connect/certs"
    forwardOriginalToken: true
  - issuer: "$EXTERNAL_PROTOCOL://$KEYCLOAK_HOST/auth/realms/$SELDON_DEPLOY_KEYCLOAK_REALM"
    jwksUri: "$EXTERNAL_PROTOCOL://$KEYCLOAK_HOST/auth/realms/$SELDON_DEPLOY_KEYCLOAK_REALM/protocol/openid-connect/certs"
    forwardOriginalToken: true
    outputPayloadToHeader: "Seldon-Core-User"
EOF


kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: seldon-core-auth-policy
  namespace: istio-system
spec:
  selector:
    matchLabels:
       istio: ingressgateway
  action: DENY
  rules:
  - to:
    - operation:
        paths: ["/seldon/*"]
    from:
    - source:
        notRequestPrincipals: ["$EXTERNAL_PROTOCOL://$KEYCLOAK_HOST/auth/realms/$SELDON_DEPLOY_KEYCLOAK_REALM/*"]
EOF

# kubectl -n istio-system delete requestauthentication seldon-core-requests-auth
# kubectl -n istio-system delete authorizationpolicies.security.istio.io  seldon-core-auth-policy