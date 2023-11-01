# sonarqube

![Version: 8.0.2-bb.1](https://img.shields.io/badge/Version-8.0.2--bb.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 9.9.2](https://img.shields.io/badge/AppVersion-9.9.2-informational?style=flat-square)

SonarQube offers Code Quality and Code Security analysis for up to 27 languages. Find Bugs, Vulnerabilities, Security Hotspots and Code Smells throughout your workflow.

## Upstream References
* <https://www.sonarqube.org/>

* <https://github.com/SonarSource/docker-sonarqube>
* <https://github.com/SonarSource/sonarqube>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Kubernetes: `>= 1.19.0-0`

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install sonarqube chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| deploymentType | string | `"StatefulSet"` |  |
| replicaCount | int | `1` |  |
| deploymentStrategy | object | `{}` |  |
| OpenShift.enabled | bool | `false` |  |
| OpenShift.createSCC | bool | `true` |  |
| edition | string | `"community"` |  |
| image.repository | string | `"registry1.dso.mil/ironbank/big-bang/sonarqube-9"` |  |
| image.tag | string | `"9.9.2-community"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.pullSecrets[0].name | string | `"private-registry"` |  |
| securityContext.fsGroup | int | `1000` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.runAsGroup | int | `1000` |  |
| containerSecurityContext.runAsUser | int | `1000` |  |
| containerSecurityContext.runAsGroup | int | `1000` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| elasticsearch.configureNode | bool | `false` |  |
| elasticsearch.bootstrapChecks | bool | `true` |  |
| nginx.enabled | bool | `false` |  |
| service.type | string | `"ClusterIP"` |  |
| service.externalPort | int | `9000` |  |
| service.internalPort | int | `9000` |  |
| service.labels | string | `nil` |  |
| service.annotations | object | `{}` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.prometheusNamespace | string | `"monitoring"` |  |
| nginx.enabled | bool | `false` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].name | string | `"sonarqube.your-org.com"` |  |
| ingress.hosts[0].path | string | `"/"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"64m"` |  |
| ingress.tls | list | `[]` |  |
| route.enabled | bool | `false` |  |
| route.host | string | `""` |  |
| route.tls.termination | string | `"edge"` |  |
| route.annotations | object | `{}` |  |
| affinity | object | `{}` |  |
| tolerations | list | `[]` |  |
| nodeSelector | object | `{}` |  |
| hostAliases | list | `[]` |  |
| readinessProbe.initialDelaySeconds | int | `60` |  |
| readinessProbe.periodSeconds | int | `30` |  |
| readinessProbe.failureThreshold | int | `6` |  |
| readinessProbe.sonarWebContext | string | `"/"` |  |
| livenessProbe.initialDelaySeconds | int | `60` |  |
| livenessProbe.periodSeconds | int | `30` |  |
| livenessProbe.failureThreshold | int | `6` |  |
| livenessProbe.sonarWebContext | string | `"/"` |  |
| startupProbe.initialDelaySeconds | int | `30` |  |
| startupProbe.periodSeconds | int | `10` |  |
| startupProbe.failureThreshold | int | `24` |  |
| startupProbe.sonarWebContext | string | `"/"` |  |
| initContainers.image | string | `"registry1.dso.mil/ironbank/big-bang/base:2.0.0"` |  |
| initContainers.resources.limits.memory | string | `"300Mi"` |  |
| initContainers.resources.limits.cpu | string | `"50m"` |  |
| initContainers.resources.requests.memory | string | `"300Mi"` |  |
| initContainers.resources.requests.cpu | string | `"50m"` |  |
| initContainers.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| extraInitContainers | object | `{}` |  |
| extraContainers | list | `[]` |  |
| waitForDb.image | string | `"registry1.dso.mil/ironbank/opensource/postgres/postgresql12:12.16"` |  |
| caCerts.enabled | bool | `false` |  |
| initSysctl.enabled | bool | `false` |  |
| initSysctl.vmMaxMapCount | int | `524288` |  |
| initSysctl.fsFileMax | int | `131072` |  |
| initSysctl.nofile | int | `131072` |  |
| initSysctl.nproc | int | `8192` |  |
| initSysctl.securityContext.privileged | bool | `true` |  |
| initSysctl.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| initFs.enabled | bool | `false` |  |
| initFs.securityContext.privileged | bool | `true` |  |
| prometheusExporter.enabled | bool | `false` |  |
| plugins.install | list | `[]` |  |
| plugins.image | string | `"registry1.dso.mil/ironbank/big-bang/sonarqube-9:9.9.2-community"` |  |
| plugins.noCheckCertificate | bool | `false` |  |
| plugins.securityContext.runAsUser | int | `1000` |  |
| plugins.securityContext.runAsGroup | int | `1000` |  |
| jvmOpts | string | `""` |  |
| jvmCeOpts | string | `""` |  |
| monitoringPasscode | string | `"define_it"` |  |
| env[0].name | string | `"JDK_JAVA_OPTIONS"` |  |
| env[0].value | string | `"-Dcom.redhat.fips=false"` |  |
| annotations | object | `{}` |  |
| resources.limits.cpu | string | `"300m"` |  |
| resources.limits.memory | string | `"2.5Gi"` |  |
| resources.requests.cpu | string | `"300m"` |  |
| resources.requests.memory | string | `"2.5Gi"` |  |
| persistence.enabled | bool | `false` |  |
| persistence.annotations | object | `{}` |  |
| persistence.storageClass | string | `nil` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.size | string | `"10Gi"` |  |
| persistence.uid | int | `1000` |  |
| persistence.volumes | list | `[]` |  |
| persistence.mounts | list | `[]` |  |
| emptyDir | object | `{}` |  |
| sonarProperties."sonar.forceAuthentication" | bool | `true` |  |
| sonarProperties."sonar.ce.javaAdditionalOpts" | string | `"-Dcom.redhat.fips=false"` |  |
| sonarProperties."sonar.search.javaAdditionalOpts" | string | `"-Dcom.redhat.fips=false"` |  |
| sonarProperties."sonar.web.javaAdditionalOpts" | string | `"-Dcom.redhat.fips=false"` |  |
| jdbcOverwrite.enable | bool | `false` |  |
| jdbcOverwrite.jdbcUsername | string | `"sonarUser"` |  |
| jdbcOverwrite.jdbcPassword | string | `"sonarPass"` |  |
| postgresql.enabled | bool | `true` |  |
| postgresql.postgresqlUsername | string | `"sonarUser"` |  |
| postgresql.postgresqlPassword | string | `"sonarPass"` |  |
| postgresql.postgresqlDatabase | string | `"sonarDB"` |  |
| postgresql.service.port | int | `5432` |  |
| postgresql.resources.limits.cpu | string | `"100m"` |  |
| postgresql.resources.limits.memory | string | `"200Mi"` |  |
| postgresql.resources.requests.cpu | string | `"100m"` |  |
| postgresql.resources.requests.memory | string | `"200Mi"` |  |
| postgresql.image.registry | string | `"registry1.dso.mil"` |  |
| postgresql.image.repository | string | `"ironbank/opensource/postgres/postgresql12"` |  |
| postgresql.image.tag | string | `"12.16"` |  |
| postgresql.image.pullSecrets[0] | string | `"private-registry"` |  |
| postgresql.postgresqlConfiguration.listen_addresses | string | `"*"` |  |
| postgresql.pgHbaConfiguration | string | `"local all all md5\nhost all all all md5"` |  |
| postgresql.persistence.enabled | bool | `true` |  |
| postgresql.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| postgresql.persistence.size | string | `"20Gi"` |  |
| postgresql.persistence.storageClass | string | `nil` |  |
| postgresql.persistence.mountPath | string | `"/var/lib/postgresql"` |  |
| postgresql.postgresqlDataDir | string | `"/var/lib/postgresql/data"` |  |
| postgresql.volumePermissions.enabled | bool | `false` |  |
| postgresql.serviceAccount.enabled | bool | `true` |  |
| postgresql.serviceAccount.automountServiceAccountToken | bool | `false` |  |
| postgresql.securityContext.enabled | bool | `true` |  |
| postgresql.securityContext.fsGroup | int | `26` |  |
| postgresql.securityContext.runAsUser | int | `26` |  |
| postgresql.securityContext.runAsGroup | int | `26` |  |
| postgresql.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| podLabels | object | `{}` |  |
| sonarqubeFolder | string | `"/opt/sonarqube"` |  |
| tests.image | string | `"bitnami/minideb-extras"` |  |
| tests.enabled | bool | `false` |  |
| tests.resources | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.automountToken | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| extraConfig.secrets | list | `[]` |  |
| extraConfig.configmaps | list | `[]` |  |
| terminationGracePeriodSeconds | int | `60` |  |
| domain | string | `"bigbang.dev"` |  |
| istio.enabled | bool | `false` |  |
| istio.mtls | object | `{"mode":"STRICT"}` | Default argocd peer authentication |
| istio.mtls.mode | string | `"STRICT"` | STRICT = Allow only mutual TLS traffic, PERMISSIVE = Allow both plain text and mutual TLS traffic |
| istio.sonarqube.enabled | bool | `true` |  |
| istio.sonarqube.annotations | object | `{}` |  |
| istio.sonarqube.labels | object | `{}` |  |
| istio.sonarqube.gateways[0] | string | `"istio-system/main"` |  |
| istio.sonarqube.hosts[0] | string | `"sonarqube.{{ .Values.domain }}"` |  |
| istio.injection | string | `"disabled"` |  |
| monitoring.enabled | bool | `false` |  |
| networkPolicies.enabled | bool | `false` |  |
| networkPolicies.ingressLabels.app | string | `"istio-ingressgateway"` |  |
| networkPolicies.ingressLabels.istio | string | `"ingressgateway"` |  |
| networkPolicies.egressHttps.enabled | bool | `true` |  |
| bbtests.enabled | bool | `false` |  |
| bbtests.cypress.artifacts | bool | `true` |  |
| bbtests.cypress.envs.cypress_url | string | `"http://sonarqube-sonarqube:9000"` |  |
| bbtests.cypress.envs.cypress_url_setup | string | `"http://sonarqube-sonarqube:9000/setup"` |  |
| bbtests.cypress.envs.cypress_user | string | `"admin"` |  |
| bbtests.cypress.envs.cypress_password | string | `"new_admin_password"` |  |
| bbtests.cypress.envs.cypress_timeout | string | `"10000"` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
