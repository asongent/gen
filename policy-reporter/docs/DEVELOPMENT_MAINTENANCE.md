# How to upgrade the Kyverno Policy Reporter Package chart
1. Checkout the branch that renovate created. This branch will have the image tag updates and typically some other necessary version changes that you will want. You can either work off of this branch or branch off of it.
1. Find the latest upstream chart version that corresponds to the new image version. Typically check the `appVersion` [here](https://github.com/kyverno/policy-reporter/blob/main/charts/policy-reporter/Chart.yaml) and find the newest tag where this matches the image tag. Git tags are in the format `policy-reporter-x.y.z`.
1. Update the chart via `kpt`, using the version you just found. You should be able to run `kpt pkg update chart@<version> --strategy alpha-git-patch` (ex: `kpt pkg update chart@policy-reporter-2.11.0 --strategy alpha-git-patch`). NOTE: If you feel confident that all BB changes are captured, you can run `--strategy force-delete-replace` since it is the safest to ensure we get all upstream changes.
1. Follow the section below for [modifications from upstream](#modifications-from-upstream) to restore all of the Big Bang specific changes.
1. Validate versioning for `Chart.yaml` (this generally should be complete between renovate + restoring the modifications). `appVersion` should equal the new image version, `version` should be the upstream version with `-bb.0` appended.
1. Add a changelog entry for the new chart version. At minimum mention the new upstream chart version and new image version(s).
1. Update the readme following the [instructions from gluon](https://repo1.dso.mil/platform-one/big-bang/apps/library-charts/gluon/-/blob/master/docs/bb-package-readme.md).
1. Push up all changes and open an MR (or use the one opened by Renovate). Validate the pipeline passes, then proceed to the [testing section](#testing-new-kyverno-reporter-version). Adjust CI tests if needed based on package changes.

# Modifications from Upstream

This is a high level list of all changes from the upstream chart. Ensure that these changes are maintained across updates.

## chart/templates/bigbang
- This folder contains networkpolicies and peerauthentication resources
- Can be restored after a kpt update with `git restore chart/templates/bigbang`

## chart/templates/cronjob-summary-report.yaml
    ```
- Update to use `tpl` for `.Values.podLabels `
    ```

## chart/templates/cronjob-violations-report.yaml
   ```
- Update to use `tpl` for `.Values.podLabels `
  ```

## chart/templates/deployment.yaml
   ```
- Update to use `tpl` for `.Values.podLabels `
  ```
## chart/tests/cypress
- This folder contains cypress tests for CI testing of the reporter
- Can be restored after a kpt update with `git restore chart/tests/cypress`

## chart/templates/tests
- This folder contains manifests to run the cypress tests in CI
- Can be restored after a kpt update with `git restore chart/templates/tests`

## chart/Chart.yaml
- Add `-bb.0` (or applicable bb version) to the version
- Add gluon library as a dependency (and run `helm dependency update chart`)
- Add the Big Bang version annotation to support release engineering automation
- Modified chart name to `kyverno-reporter` for name standardization

## chart/charts/kyvernoPlugin/values.yaml
- Update to point to the Ironbank image for `policy-reporter-kyverno-plugin`

## chart/values.yaml
- Update to point to the Ironbank image for `policy-reporter`
- Addition of values for `networkPolicies`, `openshift`, `istio`, and `bbtests`
- Addition of `securityContext.runAsGroup` set to `1234`
- Addition of value `serviceAccount.automountServiceAccountToken`, set to `false` (but is overridden at the Pod spec level to maintain access to K8s API)

## chart/charts/monitoring/values.yaml
- Added `scheme` and `tlsConfig` to both `kyverno.serviceMonitor` and `serviceMonitor` fields

## chart/charts/monitoring/templates/kyverno-servicemonitor.yaml
- Added template fields to insert values added in `monitoring/values.yaml`
```
{{- if .Values.serviceMonitor.scheme }}
scheme: {{ .Values.serviceMonitor.scheme }}
{{- end }}
{{- if .Values.serviceMonitor.tlsConfig }}
tlsConfig:
    {{- toYaml .Values.serviceMonitor.tlsConfig | nindent 8 }}
{{- end }}
```
# Deploy kyvernoReporter as part of Big Bang

- Create a k8s dev environment. One option is to use the Big Bang k3d-dev.sh with no arguments which will give you the default configuration. The following steps assume you are using the script.
- Follow the instructions at the end of the script to connect to the k8s cluster and install flux.
- Deploy kyvernoReporter with these dev values overrides. Core apps are disabled for quick deployment.
```
kyvernoReporter:
  enabled: true
  sourceType: "git"
  git:
    repo: https://repo1.dso.mil/big-bang/product/packages/kyverno-reporter.git
    path: chart
    tag: null
    branch: "replace-me-with-your-branch-name"
```
- A more robust option is to deploy Big Bang with Istio, Monitoring, Kyverno, and KyvernoPolicies enabled such as:
```
istioOperator:
  enabled: true
istio:
  enabled: true
kyverno:
  enabled: true
kyvernoPolicies:
  enabled: true
kyvernoReporter:
  enabled: true
  git:
    repo: https://repo1.dso.mil/big-bang/product/packages/kyverno-reporter.git
    path: chart
    tag: null
    branch: "replace-me-with-your-branch-name"
monitoring:
  enabled: true
```

# Testing new Kyverno Reporter version

Pipeline tests will validate all basic functionality of monitoring components (servicemonitor healthy in prometheus + dashboards show in grafana with data).

Since the pipeline does not install Istio and the package is currently not part of the umbrella chart, it is advised to deploy locally for some basic testing of Istio injection/mTLS. You can follow the below instructions to install it on top of an umbrella deployment. Follow the steps below for manual testing. For automated CI testing follow the steps in [integration_testing](integration_testing.md) .

1. Deploy the Big Bang chart with Istio, Kyverno, Kyverno Policies, and Monitoring enabled.
1. Create a new namespace to deploy Kyverno Reporter into with `kubectl create ns kyverno-reporter`.
1. Label the namespace for istio injection with `kubectl label ns kyverno-reporter istio-injection=enabled`.
1. Add image pull secrets for Kyverno Reporter. One of the easy ways to do this is by copying from another namespace with `kubectl get secret private-registry -n=istio-system -o yaml | sed 's/namespace: .*/namespace: kyverno-reporter/' | kubectl apply -n=kyverno-reporter -f -`.
1. Deploy Kyverno Reporter with a modified version of the test values using `helm upgrade -i kyverno-reporter chart -n kyverno-reporter -f tests/test-values.yaml --set istio.enabled=true --set networkPolicies.controlPlaneCidr=$(kubectl get endpoints kubernetes -ojsonpath='{.subsets[0].addresses[0].ip}' 2>/dev/null)/32`. The `--set` overrides here will ensure that network policies function appropriately for your deployment. Alternatively you could modify the test-values or point to a different override when you install.
1. Navigate to the [Prometheus targets page](https://prometheus.bigbang.dev/targets) and validate that the Kyverno Reporter servicemonitor shows up and is healthy.
1. Navigate to Grafana and search for [polcy dashboards](https://grafana.bigbang.dev/?orgId=1&search=open&query=policy). Validate that 3 dashboards appear in the search and data is loaded in each. It can be helpful to deploy an additional package at this point to cause some additional policy violations/reports.
1. Perform any additional testing (of specific new features, specific connections, etc) as needed.
1. Uninstall as needed with `helm uninstall kyverno-reporter -n kyverno-reporter` or test changes iteratively by re-running the above `helm upgrade` command.
1. [test-package-against-bb](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/docs/developer/test-package-against-bb.md?ref_type=heads) and modify test-values with the following settings:
    ```yaml
    istioOperator:
    enabled: true
    istio:
    enabled: true
    kyverno:
    enabled: true
    kyvernoPolicies:
    enabled: true
    kyvernoReporter:
    enabled: true
    git:
        repo: https://repo1.dso.mil/big-bang/product/packages/kyverno-reporter.git
        path: chart
        tag: null
        branch: "replace-me-with-your-branch-name"
    monitoring:
    enabled: true
    ```
