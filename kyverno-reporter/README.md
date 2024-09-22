<!-- Warning: Do not manually edit this file. See notes on gluon + helm-docs at the end of this file for more information. -->
# kyverno-reporter

![Version: 2.24.1-bb.1](https://img.shields.io/badge/Version-2.24.1--bb.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.20.1](https://img.shields.io/badge/AppVersion-2.20.1-informational?style=flat-square)

Policy Reporter watches for PolicyReport Resources.
It creates Prometheus Metrics and can send rule validation events to different targets like Loki, Elasticsearch, Slack or Discord

## Upstream References

* <https://kyverno.github.io/policy-reporter>

* <https://github.com/kyverno/policy-reporter>

### Upstream Release Notes

* [Find our upstream chart's CHANGELOG here](https://github.com/kyverno/policy-reporter/blob/main/CHANGELOG.md)
* [and our upstream application release notes here](https://github.com/kyverno/kyverno/releases)

## Learn More

* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

<https://helm.sh/docs/intro/install/>

## Deployment

* Clone down the repository
* cd into directory

```bash
helm install kyverno-reporter chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nameOverride | string | `""` |  |
| image.registry | string | `"registry1.dso.mil"` |  |
| image.repository | string | `"ironbank/opensource/kyverno/policy-reporter"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.tag | string | `"2.20.1"` |  |
| imagePullSecrets | list | `[]` |  |
| priorityClassName | string | `""` |  |
| replicaCount | int | `1` |  |
| revisionHistoryLimit | int | `10` |  |
| deploymentStrategy | object | `{}` |  |
| port.name | string | `"http"` |  |
| port.number | int | `8080` |  |
| annotations | object | `{}` |  |
| rbac.enabled | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.name | string | `""` |  |
| serviceAccount.automountServiceAccountToken | bool | `false` |  |
| service.enabled | bool | `true` |  |
| service.annotations | object | `{}` |  |
| service.labels | object | `{}` |  |
| service.type | string | `"ClusterIP"` |  |
| service.port | int | `8080` |  |
| podSecurityContext.fsGroup | int | `1234` |  |
| securityContext.runAsUser | int | `1234` |  |
| securityContext.runAsGroup | int | `1234` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.privileged | bool | `false` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| envVars | list | `[]` |  |
| resources | object | `{}` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.egress[0].to | string | `nil` |  |
| networkPolicy.egress[0].ports[0].protocol | string | `"TCP"` |  |
| networkPolicy.egress[0].ports[0].port | int | `6443` |  |
| networkPolicy.ingress | list | `[]` |  |
| ingress.enabled | bool | `false` |  |
| ingress.className | string | `""` |  |
| ingress.labels | object | `{}` |  |
| ingress.annotations | object | `{}` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths | list | `[]` |  |
| ingress.tls | list | `[]` |  |
| logging.encoding | string | `"console"` |  |
| logging.logLevel | int | `0` |  |
| logging.development | bool | `false` |  |
| api.logging | bool | `false` |  |
| rest.enabled | bool | `false` |  |
| metrics.enabled | bool | `false` |  |
| metrics.mode | string | `"detailed"` |  |
| metrics.customLabels | list | `[]` |  |
| profiling.enabled | bool | `false` |  |
| worker | int | `5` |  |
| reportFilter.namespaces.include | list | `[]` |  |
| reportFilter.namespaces.exclude | list | `[]` |  |
| reportFilter.clusterReports.disabled | bool | `false` |  |
| sourceConfig | object | `{}` |  |
| ui.enabled | bool | `false` |  |
| kyvernoPlugin.enabled | bool | `false` |  |
| monitoring.enabled | bool | `false` |  |
| database.type | string | `""` |  |
| database.database | string | `""` |  |
| database.username | string | `""` |  |
| database.password | string | `""` |  |
| database.host | string | `""` |  |
| database.enableSSL | bool | `false` |  |
| database.dsn | string | `""` |  |
| database.secretRef | string | `""` |  |
| database.mountedSecret | string | `""` |  |
| global.plugins.kyverno | bool | `false` |  |
| global.backend | string | `""` |  |
| global.fullnameOverride | string | `""` |  |
| global.namespace | string | `""` |  |
| global.labels | object | `{}` |  |
| global.basicAuth.username | string | `""` |  |
| global.basicAuth.password | string | `""` |  |
| global.basicAuth.secretRef | string | `""` |  |
| emailReports.clusterName | string | `""` |  |
| emailReports.titlePrefix | string | `"Report"` |  |
| emailReports.smtp.secret | string | `""` |  |
| emailReports.smtp.host | string | `""` |  |
| emailReports.smtp.port | int | `465` |  |
| emailReports.smtp.username | string | `""` |  |
| emailReports.smtp.password | string | `""` |  |
| emailReports.smtp.from | string | `""` |  |
| emailReports.smtp.encryption | string | `""` |  |
| emailReports.smtp.skipTLS | bool | `false` |  |
| emailReports.smtp.certificate | string | `""` |  |
| emailReports.summary.enabled | bool | `false` |  |
| emailReports.summary.schedule | string | `"0 8 * * *"` |  |
| emailReports.summary.activeDeadlineSeconds | int | `300` |  |
| emailReports.summary.backoffLimit | int | `3` |  |
| emailReports.summary.ttlSecondsAfterFinished | int | `0` |  |
| emailReports.summary.restartPolicy | string | `"Never"` |  |
| emailReports.summary.to | list | `[]` |  |
| emailReports.summary.filter | object | `{}` |  |
| emailReports.summary.channels | list | `[]` |  |
| emailReports.violations.enabled | bool | `false` |  |
| emailReports.violations.schedule | string | `"0 8 * * *"` |  |
| emailReports.violations.activeDeadlineSeconds | int | `300` |  |
| emailReports.violations.backoffLimit | int | `3` |  |
| emailReports.violations.ttlSecondsAfterFinished | int | `0` |  |
| emailReports.violations.restartPolicy | string | `"Never"` |  |
| emailReports.violations.to | list | `[]` |  |
| emailReports.violations.filter | object | `{}` |  |
| emailReports.violations.channels | list | `[]` |  |
| emailReports.resources | object | `{}` |  |
| existingTargetConfig.enabled | bool | `false` |  |
| existingTargetConfig.name | string | `""` |  |
| existingTargetConfig.subPath | string | `""` |  |
| target.loki.host | string | `""` |  |
| target.loki.certificate | string | `""` |  |
| target.loki.skipTLS | bool | `false` |  |
| target.loki.secretRef | string | `""` |  |
| target.loki.mountedSecret | string | `""` |  |
| target.loki.path | string | `""` |  |
| target.loki.minimumPriority | string | `""` |  |
| target.loki.sources | list | `[]` |  |
| target.loki.skipExistingOnStartup | bool | `true` |  |
| target.loki.customLabels | object | `{}` |  |
| target.loki.headers | object | `{}` |  |
| target.loki.username | string | `""` |  |
| target.loki.password | string | `""` |  |
| target.loki.filter | object | `{}` |  |
| target.loki.channels | list | `[]` |  |
| target.elasticsearch.host | string | `""` |  |
| target.elasticsearch.certificate | string | `""` |  |
| target.elasticsearch.skipTLS | bool | `false` |  |
| target.elasticsearch.index | string | `""` |  |
| target.elasticsearch.username | string | `""` |  |
| target.elasticsearch.password | string | `""` |  |
| target.elasticsearch.apiKey | string | `""` |  |
| target.elasticsearch.secretRef | string | `""` |  |
| target.elasticsearch.mountedSecret | string | `""` |  |
| target.elasticsearch.rotation | string | `""` |  |
| target.elasticsearch.minimumPriority | string | `""` |  |
| target.elasticsearch.sources | list | `[]` |  |
| target.elasticsearch.skipExistingOnStartup | bool | `true` |  |
| target.elasticsearch.typelessApi | bool | `false` |  |
| target.elasticsearch.customFields | object | `{}` |  |
| target.elasticsearch.filter | object | `{}` |  |
| target.elasticsearch.channels | list | `[]` |  |
| target.slack.webhook | string | `""` |  |
| target.slack.channel | string | `""` |  |
| target.slack.secretRef | string | `""` |  |
| target.slack.mountedSecret | string | `""` |  |
| target.slack.minimumPriority | string | `""` |  |
| target.slack.sources | list | `[]` |  |
| target.slack.skipExistingOnStartup | bool | `true` |  |
| target.slack.customFields | object | `{}` |  |
| target.slack.filter | object | `{}` |  |
| target.slack.channels | list | `[]` |  |
| target.discord.webhook | string | `""` |  |
| target.discord.secretRef | string | `""` |  |
| target.discord.mountedSecret | string | `""` |  |
| target.discord.minimumPriority | string | `""` |  |
| target.discord.sources | list | `[]` |  |
| target.discord.skipExistingOnStartup | bool | `true` |  |
| target.discord.filter | object | `{}` |  |
| target.discord.channels | list | `[]` |  |
| target.teams.webhook | string | `""` |  |
| target.teams.secretRef | string | `""` |  |
| target.teams.mountedSecret | string | `""` |  |
| target.teams.certificate | string | `""` |  |
| target.teams.skipTLS | bool | `false` |  |
| target.teams.minimumPriority | string | `""` |  |
| target.teams.sources | list | `[]` |  |
| target.teams.skipExistingOnStartup | bool | `true` |  |
| target.teams.filter | object | `{}` |  |
| target.teams.channels | list | `[]` |  |
| target.ui.host | string | `""` |  |
| target.ui.certificate | string | `""` |  |
| target.ui.skipTLS | bool | `false` |  |
| target.ui.minimumPriority | string | `"warning"` |  |
| target.ui.sources | list | `[]` |  |
| target.ui.skipExistingOnStartup | bool | `true` |  |
| target.webhook.host | string | `""` |  |
| target.webhook.certificate | string | `""` |  |
| target.webhook.skipTLS | bool | `false` |  |
| target.webhook.secretRef | string | `""` |  |
| target.webhook.mountedSecret | string | `""` |  |
| target.webhook.headers | object | `{}` |  |
| target.webhook.minimumPriority | string | `""` |  |
| target.webhook.sources | list | `[]` |  |
| target.webhook.skipExistingOnStartup | bool | `true` |  |
| target.webhook.customFields | object | `{}` |  |
| target.webhook.filter | object | `{}` |  |
| target.webhook.channels | list | `[]` |  |
| target.telegram.token | string | `""` |  |
| target.telegram.chatID | string | `""` |  |
| target.telegram.host | string | `""` |  |
| target.telegram.certificate | string | `""` |  |
| target.telegram.skipTLS | bool | `false` |  |
| target.telegram.secretRef | string | `""` |  |
| target.telegram.mountedSecret | string | `""` |  |
| target.telegram.headers | object | `{}` |  |
| target.telegram.minimumPriority | string | `""` |  |
| target.telegram.sources | list | `[]` |  |
| target.telegram.skipExistingOnStartup | bool | `true` |  |
| target.telegram.customFields | object | `{}` |  |
| target.telegram.filter | object | `{}` |  |
| target.telegram.channels | list | `[]` |  |
| target.googleChat.webhook | string | `""` |  |
| target.googleChat.certificate | string | `""` |  |
| target.googleChat.skipTLS | bool | `false` |  |
| target.googleChat.secretRef | string | `""` |  |
| target.googleChat.mountedSecret | string | `""` |  |
| target.googleChat.headers | object | `{}` |  |
| target.googleChat.minimumPriority | string | `""` |  |
| target.googleChat.sources | list | `[]` |  |
| target.googleChat.skipExistingOnStartup | bool | `true` |  |
| target.googleChat.customFields | object | `{}` |  |
| target.googleChat.filter | object | `{}` |  |
| target.googleChat.channels | list | `[]` |  |
| target.s3.accessKeyID | string | `""` |  |
| target.s3.secretAccessKey | string | `""` |  |
| target.s3.secretRef | string | `""` |  |
| target.s3.mountedSecret | string | `""` |  |
| target.s3.region | string | `""` |  |
| target.s3.endpoint | string | `""` |  |
| target.s3.bucket | string | `""` |  |
| target.s3.bucketKeyEnabled | bool | `false` |  |
| target.s3.kmsKeyId | string | `""` |  |
| target.s3.serverSideEncryption | string | `""` |  |
| target.s3.pathStyle | bool | `false` |  |
| target.s3.prefix | string | `""` |  |
| target.s3.minimumPriority | string | `""` |  |
| target.s3.sources | list | `[]` |  |
| target.s3.skipExistingOnStartup | bool | `true` |  |
| target.s3.customFields | object | `{}` |  |
| target.s3.filter | object | `{}` |  |
| target.s3.channels | list | `[]` |  |
| target.kinesis.accessKeyID | string | `""` |  |
| target.kinesis.secretAccessKey | string | `""` |  |
| target.kinesis.secretRef | string | `""` |  |
| target.kinesis.mountedSecret | string | `""` |  |
| target.kinesis.region | string | `""` |  |
| target.kinesis.endpoint | string | `""` |  |
| target.kinesis.streamName | string | `""` |  |
| target.kinesis.minimumPriority | string | `""` |  |
| target.kinesis.sources | list | `[]` |  |
| target.kinesis.skipExistingOnStartup | bool | `true` |  |
| target.kinesis.customFields | object | `{}` |  |
| target.kinesis.filter | object | `{}` |  |
| target.kinesis.channels | list | `[]` |  |
| target.securityHub.accessKeyID | string | `""` |  |
| target.securityHub.secretAccessKey | string | `""` |  |
| target.securityHub.secretRef | string | `""` |  |
| target.securityHub.mountedSecret | string | `""` |  |
| target.securityHub.region | string | `""` |  |
| target.securityHub.endpoint | string | `""` |  |
| target.securityHub.accountID | string | `""` |  |
| target.securityHub.productName | string | `""` |  |
| target.securityHub.minimumPriority | string | `""` |  |
| target.securityHub.sources | list | `[]` |  |
| target.securityHub.skipExistingOnStartup | bool | `true` |  |
| target.securityHub.cleanup | bool | `false` |  |
| target.securityHub.delayInSeconds | int | `2` |  |
| target.securityHub.customFields | object | `{}` |  |
| target.securityHub.filter | object | `{}` |  |
| target.securityHub.channels | list | `[]` |  |
| target.gcs.credentials | string | `""` |  |
| target.gcs.secretRef | string | `""` |  |
| target.gcs.mountedSecret | string | `""` |  |
| target.gcs.bucket | string | `""` |  |
| target.gcs.minimumPriority | string | `""` |  |
| target.gcs.sources | list | `[]` |  |
| target.gcs.skipExistingOnStartup | bool | `true` |  |
| target.gcs.customFields | object | `{}` |  |
| target.gcs.filter | object | `{}` |  |
| target.gcs.channels | list | `[]` |  |
| leaderElection.enabled | bool | `false` |  |
| leaderElection.releaseOnCancel | bool | `true` |  |
| leaderElection.leaseDuration | int | `15` |  |
| leaderElection.renewDeadline | int | `10` |  |
| leaderElection.retryPeriod | int | `2` |  |
| redis.enabled | bool | `false` |  |
| redis.address | string | `""` |  |
| redis.database | int | `0` |  |
| redis.prefix | string | `"policy-reporter"` |  |
| redis.username | string | `""` |  |
| redis.password | string | `""` |  |
| podDisruptionBudget.minAvailable | int | `1` | Configures the minimum available pods for policy-reporter disruptions. Cannot be used if `maxUnavailable` is set. |
| podDisruptionBudget.maxUnavailable | string | `nil` | Configures the maximum unavailable pods for policy-reporter disruptions. Cannot be used if `minAvailable` is set. |
| nodeSelector | object | `{}` |  |
| tolerations | list | `[]` |  |
| affinity | object | `{}` |  |
| topologySpreadConstraints | list | `[]` |  |
| livenessProbe.httpGet.path | string | `"/healthz"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| readinessProbe.httpGet.path | string | `"/ready"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| sqliteVolume | object | `{}` |  |
| tmpVolume | object | `{}` |  |
| networkPolicies.enabled | bool | `false` |  |
| networkPolicies.controlPlaneCidr | string | `"0.0.0.0/0"` |  |
| networkPolicies.additionalPolicies | list | `[]` |  |
| extraVolumes.volumeMounts | list | `[]` |  |
| openshift | bool | `false` |  |
| istio.enabled | bool | `false` |  |
| istio.mtls.mode | string | `"STRICT"` |  |
| istio.hardened.enabled | bool | `false` |  |
| istio.hardened.outboundTrafficPolicyMode | string | `"REGISTRY_ONLY"` |  |
| istio.hardened.customServiceEntries | list | `[]` |  |
| bbtests.enabled | bool | `false` |  |
| bbtests.cypress.artifacts | bool | `true` |  |
| bbtests.cypress.envs.cypress_grafana_url | string | `"http://grafana.monitoring.svc.cluster.local"` |  |
| bbtests.cypress.envs.cypress_prometheus_url | string | `"http://monitoring-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090"` |  |
| bbtests.cypress.envs.cypress_grafana_user | string | `"admin"` |  |
| bbtests.cypress.envs.cypress_grafana_pass | string | `"prom-operator"` |  |
| bbtests.cypress.envs.cypress_reporter_ns | string | `"kyverno-reporter"` |  |
| bbtests.volumes | list | `[]` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.

---

_This file is programatically generated using `helm-docs` and some BigBang-specific templates. The `gluon` repository has [instructions for regenerating package READMEs](https://repo1.dso.mil/big-bang/product/packages/gluon/-/blob/master/docs/bb-package-readme.md)._
