# k8s-cert-manager development

## Useful Make targets:

### `helm-update-dependencies`:

Update or first-time retrieval of the original Helm archive

```shell
make helm-update-dependencies
```

### `component-apply` and `component-delete`:

Bring a component into the cluster or remove it.
```bash
make component-apply
make component-delete
```