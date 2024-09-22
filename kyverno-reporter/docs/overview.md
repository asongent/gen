# Introduction to Kyverno Reporting

## Motivation

[Policy Reporter](https://github.com/kyverno/policy-reporter) makes the results of your Kyverno validation policies visible and observable. By default, Kyverno provides the option to create your validation policies in audit or enforce mode. While enforce will block applying a manifest that violate the given policy, audit will create a report that provides information about resources that pass or fail your policies. Note that for requests that are denied by admissions control because of policy violations in enforce mode, Kubernetes resources are not created.  As such, Policy Reporter only captures the information for policies in audit mode. Because Policy Reports are Custom Resources you can access them with `kubectl get/describe`.

Policy Reporter provides also a standalone [Dashboard](https://github.com/kyverno/policy-reporter-ui) to get a graphical overview of all results with filter and an optional [Kyverno Plugin](https://github.com/kyverno/policy-reporter-kyverno-plugin) to get also information about your Kyverno policies.

## Architecture

![Image](https://kyverno.github.io/policy-reporter/images/policy-reporter.svg)

### Policy Reporter
This is the core application and watches for PolicyReport and ClusterPolicyReport  resources in the cluster. Policy Reporter uses internal listeners to react to incoming events and apply its logic to them.

* **MetricsListener** (optional) 
creates metrics based on new, updated, and removed resources

* **StoreListener** (optional) persists new resources and every change of an existing resource in an internal representation in the included SQLite database

* **ResultsListener** checks each new and updated report for new results and publishes them to all registered PolicyResultListeners

* **SendResultListener** is a PolicyResultListener and sends all new results to the configured targets

### Policy Reporter Kyverno Plugin
This component watches for Kyverno (Cluster)Policy resources, like the Policy Reporter core application for (Cluster)PolicyReport resources. The collected data is transformed into a internal format and available over the embedded HTTP server as API endpoints.

This component is independent from the Policy Reporter core application and only consumed by the Policy Reporter UI.

### Policy Reporter UI
This component is an optional, standalone UI for information provided by the Policy Reporter core application (and Policy Reporter Kyverno Plugin). This server also proxies all requests made by the UI to the Policy Reporter API.

### Kyverno Plugin
The Kyverno integration is an optional plugin. If enabled, it provides additional views about Kyverno policies. This information is provided by the Policy Reporter Kyverno Plugin which will also be proxied.

## Installation

If you have already installed Big Bang with Kyverno, Kyverno Policies, and Monitoring enabled, you can run the following to install Kyverno Reporter through Flux:

```
# Clone this repo
git clone https://repo1.dso.mil/platform-one/big-bang/apps/sandbox/kyverno-reporter.git
cd kyverno-reporter

# Create namespace
kubectl create namespace kyverno-reporter

# Clone the Iron Bank pull secret from Big Bang
kubectl get secret private-registry --namespace=kyverno -o yaml | sed 's/namespace: .*/namespace: kyverno-reporter/' | kubectl apply -f -

# Deploy Reporter
helm upgrade --install --namespace kyverno-reporter bigbang-kyverno-reporter ./bigbang
```

## Reporting

Kyverno policy reports are Kubernetes resources that provide information about policy results, including violations. Kyverno creates policy reports for each Namespace and a single cluster-level report for cluster resources.

Result entries are added to reports during the audit when policies with validationFailureAction=audit are applied to resources. Otherwise, when in enforce mode, the resource is blocked immediately upon creation and therefore no entry is created since no offending resource exists. If the created resource violates multiple rules, there will be multiple entries in the reports for the same resource. Likewise, if a resource is deleted, it will be expunged from the report simultaneously.

There are two types of reports that get created and updated by Kyverno: a ClusterPolicyReport (for cluster-scoped resources) and a PolicyReport (for Namespaced resources). The contents of these reports are determined by the violating resources and not where the rule is stored. For example, if a rule is written which validates Ingress resources, because Ingress is a Namespaced resource, any violations will show up in a PolicyReport co-located in the same Namespace as the offending resource itself, regardless if that rule was written in a Policy or a ClusterPolicy.

Note that PolicyReport and ClusterPolicyReport CRDs get installed with basic kyverno package, kyverno-reporter only uses the PolicyReport and Cluster to show them in the UI. The rest of this document describes how to trigger the reports and visualize them in the UI that is provided by kyverno-reporter.

## Example: Trigger a Policy Report

### Create a Kyverno Policy to check resource requests and limits

```
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-requests-limits
  annotations:
    policies.kyverno.io/title: Require Limits and Requests
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
 spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: validate-resources
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "CPU and memory resource requests and limits are required."
      pattern:
        spec:
          containers:
          - resources:
              requests:
                memory: "?*"
                cpu: "?*"
              limits:
                memory: "?*"
```

### Create a Pod

```
kubectl run nginx --image nginx
```

### Get Policy Report

```
kubectl get polr

NAME              PASS   FAIL   WARN   ERROR   SKIP   AGE
polr-ns-default   1      1      0      0       0      4d10h
```

### View Policy Report

```

kubectl get polr polr-ns-default -o=yaml

apiVersion: wgpolicyk8s.io/v1alpha2
kind: PolicyReport
metadata:
  labels:
    managed-by: kyverno
  name: polr-ns-default
  namespace: default
 results:
- category: Best Practices
  message: 'validation error: CPU and memory resource requests and limits are required.
    Rule validate-resources failed at path /spec/containers/0/resources/requests/'
  policy: require-requests-limits
  resources:
  - apiVersion: v1
    kind: Pod
    name: nginx
    namespace: default
    uid: fc8447fd-0078-48f2-9d49-4764369357b1
  result: fail
  rule: validate-resources
  scored: true
  severity: medium
  source: Kyverno
  timestamp:
    nanos: 0
    seconds: 1650335041
summary:
  error: 0
  fail: 1
  pass: 1
  skip: 0
  warn: 0
```

## Example: Trigger a Cluster Policy Report

A ClusterPolicyReport is the same concept as a PolicyReport only it contains resources which are cluster scoped rather than namespaced.

As an example, create the following sample ClusterPolicy containing a single rule which validates that all new Namespaces should contain the label called maintainer and have some value.

### Create the Policy

```
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-ns-labels
spec:
  validationFailureAction: audit
  background: true
  rules:
  - name: check-for-labels-on-namespace
    match:
      any:
      - resources:
          kinds:
          - Namespace
    validate:
      message: "The label `maintainer` is required."
      pattern:
        metadata:
          labels:
            maintainer: "?*"
```

### Get Cluster Policy Report 

```
kubectl get cpolr
NAME                  PASS   FAIL   WARN   ERROR   SKIP   AGE
clusterpolicyreport   0      2      0      0       0      10s
```

## Policy Reporter UI

Access Policy Reporter at http://localhost:8080 via port forwarding:

```
kubectl -n policy-reporter port-forward service/policy-reporter-ui 8080:8080 
```

![Image](https://kyverno.github.io/policy-reporter/images/screenshots/basic-ui-light.png)