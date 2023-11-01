# Upgrading to a new version

The below details the steps required to update to a new version of the Sonarqube package.

1. Do diff of [upstream chart](https://github.com/SonarSource/helm-chart-sonarqube/tree/master/charts/sonarqube-lts) between old and new release tags to become aware of any significant chart changes. A graphical diff tool such as [Meld](https://meldmerge.org/) is useful. You can see where the current helm chart came from by inspecting ```/chart/kptfile```
1. Create a development branch and merge request from the Gitlab issue.
1. Merge/Sync the new helm chart with the existing package code. A graphical diff tool like [Meld](https://meldmerge.org/) is useful. Reference the "Modifications made to upstream chart" section below. Be careful not to overwrite Big Bang Package changes that need to be kept. Note that some files will have combinations of changes that you will overwrite and changes that you keep. Stay alert. The hardest file to update is the ```/chart/values.yaml```.
1. In `chart/Chart.yaml` update gluon to the latest version and run `helm dependency update chart` from the top level of the repo to package it up.
1. Modify the `image.tag` value in `chart/values.yaml` to point to the newest version.
1. Update `chart/Chart.yaml` to the appropriate versions. The annotation version should match the ```appVersion```.
    ```yaml
    version: X.X.X-bb.X
    appVersion: X.X.X
    annotations:
      bigbang.dev/applicationVersions: |
        - Sonarqube: X.X.X
    ```
1. Update `CHANGELOG.md` adding an entry for the new version and noting all changes.
1. Generate the `README.md` updates by following the [guide in gluon](https://repo1.dso.mil/platform-one/big-bang/apps/library-charts/gluon/-/blob/master/docs/bb-package-readme.md).
1. Open an MR in "Draft" status and validate that CI passes. This will perform a number of smoke tests against the package, but it is good to manually deploy to test some things that CI doesn't.
1. Once all manual testing is complete take your MR out of "Draft" status and add the review label.

# How to test Sonarqube

Deploy and login with both admin user and sso.

## Test Basic Functionality and Monitoring

Deploy with the following Big Bang override values to test the repo job and monitoring interaction:

```yaml
clusterAuditor:
  enabled: false

gatekeeper:
  enabled: false

istiooperator:
  enabled: true

istio:
  enabled: true

jaeger:
  enabled: false

kiali:
  enabled: false

logging:
  enabled: false

eckoperator:
  enabled: false

fluentbit:
  enabled: false

monitoring:
  enabled: true

twistlock:
  enabled: false

addons:
  sonarqube:
    enabled: true
    git:
      tag: null
      branch: "name-of-your-development-branch"

```

1. Navigate to the Prometheus target page (https://prometheus.bigbang.dev/targets) and validate that the Sonarqube target shows as up.

# Modifications made to upstream chart
This is a high-level list of modifications that Big Bang has made to the upstream helm chart. You can use this as as cross-check to make sure that no modifications were lost during an upgrade process.

##  chart/charts/*.tgz
- add the gluon library archive from ```helm dependency update ./chart```

- commit the tar archives that were downloaded from the helm dependency update command. And also commit the requirements.lock that was generated.

## chart/deps/postgresql/*
- Bitnami postgres chart for development

## chart/templates/bigbang/*
- add istio VirtualService
- add ServiceMonitor
- add PeerAuthentication
- add NetworkPolicies

## chart/templates/tests/*
- add templates for helm tests sonarqube-cypress-test.yaml

## chart/templates/deployment.yaml & sonarqube-sts.yaml
- remove default images
- change waitForDb from using `nc` to a `pg_isready`
- modify caCert init container to conditionally use command/args from values

## chart/templates/install-plugins.yaml
- switched upstream cat/wget plugin install to curl

## chart/templates/change-admin-password-hook.yaml
- re-write job with istio termination
- change `hook-delete-policy` to add `before-hook-creation`

## chart/templates/NOTES.txt
- Added istio.enabled wraper

## chart/templates/_helpers.tpl
- Added define "deployment.waitForDb.compatible"
- Added define "sonarqube.chart"

## chart/tests/cypress/*
- add cypress tests

## chart/Chart.yaml
- changes for Big Bang version, gluon dependency, and annotations

# chart/Chart.lock
- add this file during helm dependency update

## chart/Kptfile
- add Kptfile

## chart/values.yaml
- Big Bang additions at the bottom of the values file
- Replace image with Iron Bank image
- add PullSecret.name = private-registry
- add fips options
- added bbtests values to support cypress/script tests
- drop all's
- enable serviceaccount creation
- set automountToken to false to maintain security posture