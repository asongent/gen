## Setting Affinity, nodeSelector, and tolerations for Sonarqube within the chart

### To enable affinity, tolerations, and nodeSelector options in the sonarqube chart set the provided values:
```
# Affinity for pod assignment
# Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
affinity: {}

# Tolerations for pod assignment
# Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
tolerations: []

# Node labels for pod assignment
# Ref: https://kubernetes.io/docs/user-guide/node-selection/
nodeSelector: {}
```
