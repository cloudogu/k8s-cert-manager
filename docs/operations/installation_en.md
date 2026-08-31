# Configuring k8s-cert-manager

The `k8s-cert-manager` component is based on the
[`cert-manager`](https://artifacthub.io/packages/helm/cert-manager/cert-manager) tool; it has been tailored for the
Cloudogu EcoSystem (CES) and consists essentially of configuration settings designed for optimization.

`cert-manager` can generate TLS certificates within Kubernetes and renew them before they expire.

## Configuration (`values.yaml`) Overview

In general, all configuration settings from the
[original cert-manager Helm chart](https://artifacthub.io/packages/helm/cert-manager/cert-manager)
are accessible via the parent property `.certmanager`. For example, `.startupapicheck.enabled`
becomes the values entry `.certmanager.startupapicheck.enabled`.

Custom configuration settings are located under the `.global` property.

| Area           | Key in `values.yaml`       | Required                                     | Effect                                                                 |
|----------------|----------------------------|----------------------------------------------|------------------------------------------------------------------------|
| Image & Pull   | `.global.imagePullSecrets` | optional, default `ces-container-registries` | List of secrets used for pulling images for CRDs.                      |
| Network Access | `.networkPolicy.enabled`   | optional, default `true`                     | Allows all cert-manager pods access to HTTP health checks and metrics. |

## Special Considerations

This component deploys Kubernetes `NetworkPolicies` that focus exclusively on ingress (as opposed to egress). This is
because a single egress `NetworkPolicy` is sufficient to block all outbound communication, provided that such
communication is not explicitly permitted by other egress `NetworkPolicies`. Within a CES instance, operational focus is
typically placed solely on ingress rules.

If the original ingress and egress `NetworkPolicies` are preferred instead, the CES-specific `NetworkPolicies` must be
disabled, and the individual cert-manager `NetworkPolicies` enabled:

```yaml
apiVersion: k8s.cloudogu.com/v1
kind: Component
#...
spec:
  name: k8s-cert-manager
  #...
  namespace: k8s
  valuesYamlOverwrite: |
    networkPolicy:
      enabled: false
    certmanager:
      networkPolicy:
        enabled: true
      webhook:
        networkPolicy: true
      cainjector:
        networkPolicy: true
  #...
```