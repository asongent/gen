---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Using the GitLab Shell chart **(FREE SELF)**

The `gitlab-shell` sub-chart provides an SSH server configured for Git SSH access to GitLab.

## Requirements

This chart depends on access to the Workhorse services, either as part of the
complete GitLab chart or provided as an external service reachable from the Kubernetes
cluster this chart is deployed onto.

## Design Choices

In order to easily support SSH replicas, and avoid using shared storage for the SSH
authorized keys, we are using the SSH [AuthorizedKeysCommand](https://man.openbsd.org/sshd_config#AuthorizedKeysCommand)
to authenticate against the GitLab authorized keys endpoint. As a result, we don't persist
or update the AuthorizedKeys file within these pods.

## Configuration

The `gitlab-shell` chart is configured in two parts: [external services](#external-services),
and [chart settings](#chart-settings). The port exposed through Ingress is configured
with `global.shell.port`, and defaults to `22`. The Service's external port is also
controlled by `global.shell.port`.

## Installation command line options

| Parameter                                       | Default                                                                                                                                                                     | Description                                                                                                                                                                                        |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `annotations`                                   |                                                                                                                                                                             | Pod annotations                                                                                                                                                                                    |
| `podLabels`                                     |                                                                                                                                                                             | Supplemental Pod labels. Will not be used for selectors.                                                                                                                                           |
| `common.labels`                                 |                                                                                                                                                                             | Supplemental labels that are applied to all objects created by this chart.                                                                                                                         |
| `config.clientAliveInterval`                    | `0`                                                                                                                                                                         | Interval between keepalive pings on otherwise idle connections; the default value of 0 disables this ping                                                                                          |
| `config.loginGraceTime`                         | `60`                                                                                                                                                                        | Specifies amount of time that the server will disconnect after if the user has not successfully logged in                                                                                          |
| `config.maxStartups.full`                       | `100`                                                                                                                                                                       | SSHd refuse probability will increase linearly and all unauthenticated connection attempts would be refused when unauthenticated connections number will reach specified number                    |
| `config.maxStartups.rate`                       | `30`                                                                                                                                                                        | SSHd will refuse connections with specified probability when there would be too many unauthenticated connections (optional)                                                                        |
| `config.maxStartups.start`                      | `10`                                                                                                                                                                        | SSHd will refuse connection attempts with some probability if there are currently more than the specified number of unauthenticated connections (optional)                                         |
| `config.proxyProtocol`                          | `false`                                                                                                                                                                     | Enable PROXY protocol support for the `gitlab-sshd` daemon                                                                                                                                         |
| `config.proxyPolicy`                            | `"use"`                                                                                                                                                                     | Specify policy for handling PROXY protocol. Value must be one of `use, require, ignore, reject`                                                                                                    |
| `config.proxyHeaderTimeout`                     | `"500ms"`                                                                                                                                                                   | The maximum duration `gitlab-sshd` will wait before giving up on reading the PROXY protocol header. Must include units: `ms`, `s`, or `m`.                                                         |
| `config.ciphers`                                | `[aes128-gcm@openssh.com, chacha20-poly1305@openssh.com, aes256-gcm@openssh.com, aes128-ctr, aes192-ctr, aes256-ctr]`                                                       | Specify the ciphers allowed.                                                                                                                                                                       |
| `config.kexAlgorithms`                          | `[curve25519-sha256, curve25519-sha256@libssh.org, ecdh-sha2-nistp256, ecdh-sha2-nistp384, ecdh-sha2-nistp521, diffie-hellman-group14-sha256, diffie-hellman-group14-sha1]` | Specifies the available KEX (Key Exchange) algorithms.                                                                                                                                             |
| `config.macs`                                   | `[hmac-sha2-256-etm@openssh.com, hmac-sha2-512-etm@openssh.com, hmac-sha2-256, hmac-sha2-512, hmac-sha1]`                                                                   | Specifies the available MAC (message authentication code algorithms.                                                                                                                               |
| `config.gssapi.enabled`                         | `false`                                                                                                                                                                     | Enable GSS-API support for the `gitlab-sshd` daemon                                                                                                                                                |
| `config.gssapi.keytab.secret`                   |                                                                                                                                                                             | The name of a Kubernetes secret holding the keytab for the gssapi-with-mic authentication method                                                                                                   |
| `config.gssapi.keytab.key`                      | `keytab`                                                                                                                                                                    | Key holding the keytab in the Kubernetes secret                                                                                                                                                    |
| `config.gssapi.krb5Config`                      |                                                                                                                                                                             | Content of the `/etc/krb5.conf` file in the GitLab Shell container                                                                                                                                 |
| `config.gssapi.servicePrincipalName`            |                                                                                                                                                                             | The Kerberos service name to be used by the `gitlab-sshd` daemon                                                                                                                                   |
| `deployment.livenessProbe.initialDelaySeconds`  | 10                                                                                                                                                                          | Delay before liveness probe is initiated                                                                                                                                                           |
| `deployment.livenessProbe.periodSeconds`        | 10                                                                                                                                                                          | How often to perform the liveness probe                                                                                                                                                            |
| `deployment.livenessProbe.timeoutSeconds`       | 3                                                                                                                                                                           | When the liveness probe times out                                                                                                                                                                  |
| `deployment.livenessProbe.successThreshold`     | 1                                                                                                                                                                           | Minimum consecutive successes for the liveness probe to be considered successful after having failed                                                                                               |
| `deployment.livenessProbe.failureThreshold`     | 3                                                                                                                                                                           | Minimum consecutive failures for the liveness probe to be considered failed after having succeeded                                                                                                 |
| `deployment.readinessProbe.initialDelaySeconds` | 10                                                                                                                                                                          | Delay before readiness probe is initiated                                                                                                                                                          |
| `deployment.readinessProbe.periodSeconds`       | 5                                                                                                                                                                           | How often to perform the readiness probe                                                                                                                                                           |
| `deployment.readinessProbe.timeoutSeconds`      | 3                                                                                                                                                                           | When the readiness probe times out                                                                                                                                                                 |
| `deployment.readinessProbe.successThreshold`    | 1                                                                                                                                                                           | Minimum consecutive successes for the readiness probe to be considered successful after having failed                                                                                              |
| `deployment.readinessProbe.failureThreshold`    | 2                                                                                                                                                                           | Minimum consecutive failures for the readiness probe to be considered failed after having succeeded                                                                                                |
| `deployment.strategy`                           | `{}`                                                                                                                                                                        | Allows one to configure the update strategy utilized by the deployment                                                                                                                             |
| `deployment.terminationGracePeriodSeconds`      | 30                                                                                                                                                                          | Seconds that Kubernetes will wait for a pod to forcibly exit                                                                                                                                       |
| `enabled`                                       | `true`                                                                                                                                                                      | Shell enable flag                                                                                                                                                                                  |
| `extraContainers`                               |                                                                                                                                                                             | List of extra containers to include                                                                                                                                                                |
| `extraInitContainers`                           |                                                                                                                                                                             | List of extra init containers to include                                                                                                                                                           |
| `extraVolumeMounts`                             |                                                                                                                                                                             | List of extra volumes mounts to do                                                                                                                                                                 |
| `extraVolumes`                                  |                                                                                                                                                                             | List of extra volumes to create                                                                                                                                                                    |
| `extraEnv`                                      |                                                                                                                                                                             | List of extra environment variables to expose                                                                                                                                                      |
| `extraEnvFrom`                                  |                                                                                                                                                                             | List of extra environment variables from other data sources to expose                                                                                                                              |
| `hpa.behavior`                                  | `{scaleDown: {stabilizationWindowSeconds: 300 }}`                                                                                                                           | Behavior contains the specifications for up- and downscaling behavior (requires `autoscaling/v2beta2` or higher)                                                                                   |
| `hpa.customMetrics`                             | `[]`                                                                                                                                                                        | Custom metrics contains the specifications for which to use to calculate the desired replica count (overrides the default use of Average CPU Utilization configured in `targetAverageUtilization`) |
| `hpa.cpu.targetType`                            | `AverageValue`                                                                                                                                                              | Set the autoscaling CPU target type, must be either `Utilization` or `AverageValue`                                                                                                                |
| `hpa.cpu.targetAverageValue`                    | `100m`                                                                                                                                                                      | Set the autoscaling CPU target value                                                                                                                                                               |
| `hpa.cpu.targetAverageUtilization`              |                                                                                                                                                                             | Set the autoscaling CPU target utilization                                                                                                                                                         |
| `hpa.memory.targetType`                         |                                                                                                                                                                             | Set the autoscaling memory target type, must be either `Utilization` or `AverageValue`                                                                                                             |
| `hpa.memory.targetAverageValue`                 |                                                                                                                                                                             | Set the autoscaling memory target value                                                                                                                                                            |
| `hpa.memory.targetAverageUtilization`           |                                                                                                                                                                             | Set the autoscaling memory target utilization                                                                                                                                                      |
| `hpa.targetAverageValue`                        |                                                                                                                                                                             | **DEPRECATED** Set the autoscaling CPU target value                                                                                                                                                |
| `image.pullPolicy`                              | `IfNotPresent`                                                                                                                                                              | Shell image pull policy                                                                                                                                                                            |
| `image.pullSecrets`                             |                                                                                                                                                                             | Secrets for the image repository                                                                                                                                                                   |
| `image.repository`                              | `registry.com/gitlab-org/build/cng/gitlab-shell`                                                                                                                            | Shell image repository                                                                                                                                                                             |
| `image.tag`                                     | `master`                                                                                                                                                                    | Shell image tag                                                                                                                                                                                    |
| `init.image.repository`                         |                                                                                                                                                                             | initContainer image                                                                                                                                                                                |
| `init.image.tag`                                |                                                                                                                                                                             | initContainer image tag                                                                                                                                                                            |
| `init.containerSecurityContext`                 |                                          | initContainer container specific [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core)                                                                                                                                                         |
| `logging.format`                                | `json`                                                                                                                                                                      | Set to `text` for unstructured logs                                                                                                                                                                |
| `logging.sshdLogLevel`                          | `ERROR`                                                                                                                                                                     | Log level for underlying SSH daemon                                                                                                                                                                |
| `priorityClassName`                             |                                                                                                                                                                             | [Priority class](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) assigned to pods.                                                                               |
| `replicaCount`                                  | `1`                                                                                                                                                                         | Shell replicas                                                                                                                                                                                     |
| `serviceLabels`                                 | `{}`                                                                                                                                                                        | Supplemental service labels                                                                                                                                                                        |
| `service.externalTrafficPolicy`                 | `Cluster`                                                                                                                                                                   | Shell service external traffic policy (Cluster or Local)                                                                                                                                           |
| `service.internalPort`                          | `2222`                                                                                                                                                                      | Shell internal port                                                                                                                                                                                |
| `service.nodePort`                              |                                                                                                                                                                             | Sets shell nodePort if set                                                                                                                                                                         |
| `service.name`                                  | `gitlab-shell`                                                                                                                                                              | Shell service name                                                                                                                                                                                 |
| `service.type`                                  | `ClusterIP`                                                                                                                                                                 | Shell service type                                                                                                                                                                                 |
| `service.loadBalancerIP`                        |                                                                                                                                                                             | IP address to assign to LoadBalancer (if supported)                                                                                                                                                |
| `service.loadBalancerSourceRanges`              |                                                                                                                                                                             | List of IP CIDRs allowed access to LoadBalancer (if supported)                                                                                                                                     |
| `securityContext.fsGroup`                       | `1000`                                                                                                                                                                      | Group ID under which the pod should be started                                                                                                                                                     |
| `securityContext.runAsUser`                     | `1000`                                                                                                                                                                      | User ID under which the pod should be started                                                                                                                                                      |
| `securityContext.fsGroupChangePolicy`           |                                                                                                                                                                             | Policy for changing ownership and permission of the volume (requires Kubernetes 1.23)                                                                                                              |
| `containerSecurityContext`                      |                                          | Override container [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core) under which the container is started                                                                                                                                  |
| `containerSecurityContext.runAsUser`            | `1000`                                   | Allow to overwrite the specific security context under which the container is started                                                                                                                                  |

| `sshDaemon`                                     | `openssh`                                                                                                                                                                   | Selects which SSH daemon would be run, possible values (`openssh`, `gitlab-sshd`)                                                                                                                  |
| `tolerations`                                   | `[]`                                                                                                                                                                        | Toleration labels for pod assignment                                                                                                                                                               |
| `workhorse.serviceName`                         | `webservice`                                                                                                                                                                | Workhorse service name (by default, Workhorse is a part of the webservice Pods / Service)                                                                                                          |
| `metrics.enabled`                               | `false`                                                                                                                                                                     | If a metrics endpoint should be made available for scraping (requires `sshDaemon=gitlab-sshd`).                                                                                                    |
| `metrics.port`                                  | `9122`                                                                                                                                                                      | Metrics endpoint port                                                                                                                                                                              |
| `metrics.path`                                  | `/metrics`                                                                                                                                                                  | Metrics endpoint path                                                                                                                                                                              |
| `metrics.serviceMonitor.enabled`                | `false`                                                                                                                                                                     | If a ServiceMonitor should be created to enable Prometheus Operator to manage the metrics scraping, note that enabling this removes the `prometheus.io` scrape annotations                         |
| `metrics.serviceMonitor.additionalLabels`       | `{}`                                                                                                                                                                        | Additional labels to add to the ServiceMonitor                                                                                                                                                     |
| `metrics.serviceMonitor.endpointConfig`         | `{}`                                                                                                                                                                        | Additional endpoint configuration for the ServiceMonitor                                                                                                                                           |
| `metrics.annotations`                           |                                                                                                                                                                             | **DEPRECATED** Set explicit metrics annotations. Replaced by template content.                                                                                                                     |

## Chart configuration examples

### extraEnv

`extraEnv` allows you to expose additional environment variables in all containers in the pods.

Below is an example use of `extraEnv`:

```yaml
extraEnv:
  SOME_KEY: some_value
  SOME_OTHER_KEY: some_other_value
```

When the container is started, you can confirm that the environment variables are exposed:

```shell
env | grep SOME
SOME_KEY=some_value
SOME_OTHER_KEY=some_other_value
```

### extraEnvFrom

`extraEnvFrom` allows you to expose additional environment variables from other data sources in all containers in the pods.

Below is an example use of `extraEnvFrom`:

```yaml
extraEnvFrom:
  MY_NODE_NAME:
    fieldRef:
      fieldPath: spec.nodeName
  MY_CPU_REQUEST:
    resourceFieldRef:
      containerName: test-container
      resource: requests.cpu
  SECRET_THING:
    secretKeyRef:
      name: special-secret
      key: special_token
      # optional: boolean
  CONFIG_STRING:
    configMapKeyRef:
      name: useful-config
      key: some-string
      # optional: boolean
```

### image.pullSecrets

`pullSecrets` allows you to authenticate to a private registry to pull images for a pod.

Additional details about private registries and their authentication methods can be
found in [the Kubernetes documentation](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod).

Below is an example use of `pullSecrets`:

```yaml
image:
  repository: my.shell.repository
  tag: latest
  pullPolicy: Always
  pullSecrets:
  - name: my-secret-name
  - name: my-secondary-secret-name
```

### livenessProbe/readinessProbe

`deployment.livenessProbe` and `deployment.readinessProbe` provide a mechanism
to help control the termination of Pods under some scenarios.

Larger repositories benefit from tuning liveness and readiness probe
times to match their typical long-running connections. Set readiness
probe duration shorter than liveness probe duration to minimize
potential interruptions during `clone` and `push` operations. Increase
`terminationGracePeriodSeconds` and give these operations more time before
the scheduler terminates the pod. Consider the example below as a starting
point to tune GitLab Shell pods for increased stability and efficiency
with larger repository workloads.

```yaml
deployment:
  livenessProbe:
    initialDelaySeconds: 10
    periodSeconds: 20
    timeoutSeconds: 3
    successThreshold: 1
    failureThreshold: 10
  readinessProbe:
    initialDelaySeconds: 10
    periodSeconds: 5
    timeoutSeconds: 2
    successThreshold: 1
    failureThreshold: 3
  terminationGracePeriodSeconds: 300
```

Reference the official [Kubernetes Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
for additional details regarding this configuration.

### tolerations

`tolerations` allow you schedule pods on tainted worker nodes

Below is an example use of `tolerations`:

```yaml
tolerations:
- key: "node_label"
  operator: "Equal"
  value: "true"
  effect: "NoSchedule"
- key: "node_label"
  operator: "Equal"
  value: "true"
  effect: "NoExecute"
```

### annotations

`annotations` allows you to add annotations to the GitLab Shell pods.

Below is an example use of `annotations`

```yaml
annotations:
  kubernetes.io/example-annotation: annotation-value
```

## External Services

This chart should be attached the Workhorse service.

### Workhorse

```yaml
workhorse:
  host: workhorse.example.com
  serviceName: webservice
  port: 8181
```

| Name          |  Type   | Default      | Description                                                                                                                                                                                                                                                                                                                                                                |
| :------------ | :-----: | :----------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `host`        | String  |              | The hostname of the Workhorse server. This can be omitted in lieu of `serviceName`.                                                                                                                                                                                                                                                                                        |
| `port`        | Integer | `8181`       | The port on which to connect to the Workhorse server.                                                                                                                                                                                                                                                                                                                      |
| `serviceName` | String  | `webservice` | The name of the `service` which is operating the Workhorse server. By default, Workhorse is a part of the webservice Pods / Service. If this is present, and `host` is not, the chart will template the hostname of the service (and current `.Release.Name`) in place of the `host` value. This is convenient when using Workhorse as a part of the overall GitLab chart. |

## Chart settings

The following values are used to configure the GitLab Shell Pods.

### hostKeys.secret

The name of the Kubernetes `secret` to grab the SSH host keys from. The keys in the
secret must start with the key names `ssh_host_` in order to be used by GitLab Shell.

### authToken

GitLab Shell uses an Auth Token in its communication with Workhorse. Share the token
with GitLab Shell and Workhorse using a shared Secret.

```yaml
authToken:
 secret: gitlab-shell-secret
 key: secret
```

| Name               |  Type  | Default | Description                                                           |
| :----------------- | :----: | :------ | :-------------------------------------------------------------------- |
| `authToken.key`    | String |         | The name of the key in the above secret that contains the auth token. |
| `authToken.secret` | String |         | The name of the Kubernetes `Secret` to pull from.                     |

### LoadBalancer Service

If the `service.type` is set to `LoadBalancer`, you can optionally specify `service.loadBalancerIP` to create
the `LoadBalancer` with a user-specified IP (if your cloud provider supports it).

You can also optionally specify a list of `service.loadBalancerSourceRanges` to restrict
the CIDR ranges that can access the `LoadBalancer` (if your cloud provider supports it).

Additional information about the `LoadBalancer` service type can be found in
[the Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/#loadbalancer)

```yaml
service:
  type: LoadBalancer
  loadBalancerIP: 1.2.3.4
  loadBalancerSourceRanges:
  - 5.6.7.8/32
  - 10.0.0.0/8
```

### Configuring the `networkpolicy`

This section controls the
[NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
This configuration is optional and is used to limit Egress and Ingress of the
Pods to specific endpoints.

| Name              |  Type   | Default | Description                                                                                                                                                                     |
| :---------------- | :-----: | :------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `enabled`         | Boolean | `false` | This setting enables the `NetworkPolicy`                                                                                                                                        |
| `ingress.enabled` | Boolean | `false` | When set to `true`, the `Ingress` network policy will be activated. This will block all Ingress connections unless rules are specified.                                         |
| `ingress.rules`   |  Array  | `[]`    | Rules for the Ingress policy, for details see <https://kubernetes.io/docs/concepts/services-networking/network-policies/#the-networkpolicy-resource> and the example below      |
| `egress.enabled`  | Boolean | `false` | When set to `true`, the `Egress` network policy will be activated. This will block all egress connections unless rules are specified.                                           |
| `egress.rules`    |  Array  | `[]`    | Rules for the egress policy, these for details see <https://kubernetes.io/docs/concepts/services-networking/network-policies/#the-networkpolicy-resource> and the example below |

### Example Network Policy

The `gitlab-shell` service requires Ingress connections for port 22 and Egress
connections to various to default workhorse port 8181. This examples adds the
following network policy:

- All Ingress requests from the network on TCP `0.0.0.0/0` port 2222 are allowed
- All Egress requests to the network on UDP `10.0.0.0/8` port 53 are allowed for DNS
- All Egress requests to the network on TCP `10.0.0.0/8` port 8181 are allowed for Workhorse
- All Egress requests to the network on TCP `10.0.0.0/8` port 8075 are allowed for Gitaly

_Note the example provided is only an example and may not be complete_

```yaml
networkpolicy:
  enabled: true
  ingress:
    enabled: true
    rules:
      - from:
        - ipBlock:
            cidr: 0.0.0.0/0
        ports:
          - port: 2222
            protocol: TCP
  egress:
    enabled: true
    rules:
      - to:
        - ipBlock:
            cidr: 10.0.0.0/8
        ports:
          - port: 8181
            protocol: TCP
          - port: 8075
            protocol: TCP
          - port: 53
            protocol: UDP
```
