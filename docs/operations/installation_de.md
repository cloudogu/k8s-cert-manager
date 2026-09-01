# k8s-cert-manager konfigurieren

Die Komponente `k8s-cert-manager` basiert auf dem Tool
[`cert-manager`](https://artifacthub.io/packages/helm/cert-manager/cert-manager), das auf das Cloudogu EcoSystem (CES)
zugeschnitten wurde und im Wesentlichen nur aus optimierenden Konfigurationspunkten besteht.

`cert-manager` kann TLS-Zertifikate innerhalb von Kubernetes erzeugen und vor dem Ablaufdatum erneuern.

## Konfiguration (`values.yaml`) im Überblick

Grundsätzlich sind alle Konfigurationspunkte
vom [originalen cert-manager-Helm-Chart](https://artifacthub.io/packages/helm/cert-manager/cert-manager) über das
übergeordnete Property `.certmanager` erreichbar. So wird z. B. aus `.startupapicheck.enabled` der Values-Eintrag
`.certmanager.startupapicheck.enabled`.

Eigene Konfigurationspunkte liegen in dem Property `.global`

| Bereich          | Schlüssel in `values.yaml` | Pflicht                                           | Wirkung                                                                   |
|------------------|----------------------------|---------------------------------------------------|---------------------------------------------------------------------------|
| Image & Pull     | `.global.imagePullSecrets` | optional, Standardwert `ces-container-registries` | Liste von Secrets, die zum Image-Pull bei CRDs verwendet werden.          |
| Netzwerkzugriffe | `.networkPolicy.enabled`   | optional, Standardwert `true`                     | Erlaubt allen cert-manager-Pods den Zugriff auf http-Health und -Metriken |

## Besonderheiten

Mit dieser Komponente werden Kubernetes `NetworkPolicies` ausgeliefert, die sich aber nur auf Ingress (im Ggs. zu
Egress) konzentrieren. Dies liegt daran, dass eine einziges Egress-NetworkPolicy ausreicht, um sämtliche
Outbound-Kommunikation zu unterdrücken, solange diese nicht ebenfalls durch Egress-NetworkPolicies geregelt werden.
Üblicherweise liegt innerhalb einer CES-Instanz der Betriebsfokus ausschließlich auf Ingress-Regelungen.

Werden lieber die original Ingress- inkl. Egress-NetworkPolicies gewünscht, so müssen die CES-spezifischen
NetworkPolicies deaktiviert und im Gegenzug die einzelnen cert-manager-NetworkPolicies aktiviert werden:

```yaml
apiVersion: k8s.cloudogu.com/v1
kind: Component
#...
spec:
  name: k8s-cert-manager
  #...
  namespace: k8s
  valuesYamlOverwrite: |
    global:
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