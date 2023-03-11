#Elastic Basic Auth

For license reasons we are using the opendistr helm chart, which has basic auth by default.

Elastic-provided elastic can also be configured with [basic auth](https://github.com/elastic/helm-charts/issues/771#issuecomment-673674876).

Note that requires an [xpack feature](https://discuss.elastic.co/t/authentication-for-kibana-unknown-setting-xpack-security-enabled/254434/2) so we can't currently use it in our trials.

For Deploy we need secrets in seldon-logs and seldon-system namespaces as Deploy needs to speak to elastic using the secret (much like with argocd).
