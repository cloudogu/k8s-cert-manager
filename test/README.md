# Kube-rbac-proxy Test

## Bootstrap issuer

Create a selfsigned Issuer, selfsigned certificate and ca issuer.
The selfsigned certificate is used as a secret for the ca issuer.

`kubectl apply -f test/issuer.yaml --namespace=ecosystem`

## Create certificate

Create a certificate signed by the ca issuer:

`kubectl apply -f test/cert.yaml --namespace=ecosystem`

The created certificate can be used by a kube rbac proxy from e.g. dogu-operator.
Mount tls key and cert from the cert-manager certificate in kube rbac proxy container.
Run the container with `--tls-cert-file` and `--tls-private-key-file` options.


See [deployment](example_operator_deploy.yaml) for an example.
