# Sonarqube 8.3 Community version [Version 8.3.1 (build 34397)] with auth oidc 2.0.0 plugin

## Table Of Contents

- Application Overview
- Usage
- Integrations
    - Prometheus
    - ECK
    - Keycloak
    - Party Bus
- Troubleshooting Tips

### Application Overview

This repo contains manifests to deploy Sonarqube static code analysis tool into a Kubernetes cluster.
Additional docs for using Sonarqube and its plugins can be found at <https://docs.sonarqube.org/latest/>


### Usage

#### Deployment Notes

Please note the settings applied in the file "sonar.properties" since they override any settings applied through the UI. [Documentation can be found here](https://docs.sonarqube.org/latest/setup/operate-cluster/#header-8) with additional properties shown in the Sonarqube instance's settings page.

:warning: Sonarqube's UI may not display the true value for settings applied through "sonar.properties"

`sonar.es.bootstrap.checks.disable=true` – Disables enforcement of [Elasticsearch and system setting checks](https://www.elastic.co/guide/en/elasticsearch/reference/current/bootstrap-checks.html).

`sonar.forceAuthentication=true` – [Restricts anonymous users from browsing the SonarQube instance](https://docs.sonarqube.org/latest/instance-administration/security/), either through the API or the web service

Please also note that appropriate secrets (listed below) should be defined before the sonarqube pod is able to connect to the postgres database and is able to function properly.
Sonarqube needs three environment variables to access the postgres database.

SONARQUBE_JDBC_URL - URL for the postgres database to use

SONARQUBE_JDBC_USERNAME - username to access the postgres database

SONARQUBE_JDBC_PASSWORD - password for the above user

These need to be added in as Kubernetes secrets and mounted into the sonarqube pod <https://kubernetes.io/docs/concepts/configuration/secret/>.

This BigBang chart has the following value fed in as a `JDK_JAVA_OPTIONS` environment variable in order to alleviate issues when running on FIPS enabled Kubernetes nodes: `-Dcom.redhat.fips=false`. If there is need to add in your own `JDK_JAVA_OPTIONS` flag ensure that that fips related flag is also present either before or after any other flags. Also if there is any other env value that is overridden into the chart please ensure you also add this YAML so the `JDK_JAVA_OPTIONS` variable is present in the deployment:

```yaml
env:
  ...
  - name: JDK_JAVA_OPTIONS
    value: "-Dcom.redhat.fips=false"
```

#### Default Admin Credentials

When installing SonarQube, a default user with administrator privileges is created automatically:

Login: admin
Password: admin

For security reasons the administrator password should be changed. This can be done from the SonarQube dashboard by following these steps:

1)Log in to the SonarQube dashboard.

2)Under the “User Name” dropdown menu in the upper right corner, click on “My Account”.

3)Select the “Security” tab.

4)Enter your old password and enter your new password twice to confirm the change.

5)Click the “Change password” button.


### Integrations

#### [Prometheus.md](Prometheus.md)
- Configuration items 
- List of metrics gathered
- Useful queries [living list]

#### [ECK.md](ECK.md)
- Configuration items
- Fluentd Pipelines
- Important Logs
- Useful queries [living list]

#### [Keycloak.md](Keycloak.md)
- Configuration items
- Add new groups
- Claim information
- OiD / SAML application items

#### [PartyBus.md](PartyBus.md)
- First time configuration
- OIDC integration
- Pipeline integration
