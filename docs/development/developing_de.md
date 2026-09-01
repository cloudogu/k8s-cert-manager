# k8s-cert-manager entwickeln

## Hilfreiche Make-Targets

### `helm-update-dependencies`:

Aktualisieren bzw. erstmaliges Holen des Original-Helm-Archives
```shell
make helm-update-dependencies
```

### `component-apply` und `component-delete`:

Komponente in den Cluster bringen bzw. wieder entfernen.
```bash
make component-apply
make component-delete
```
