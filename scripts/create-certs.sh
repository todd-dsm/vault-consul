#!/usr/bin/env bash
set -x

# Create a Certificate Authority:

cfssl gencert -initca certs/config/ca-csr.json | cfssljson -bare certs/ca

# create a private key and a TLS certificate for Consul:
cfssl gencert \
    -ca=certs/ca.pem \
    -ca-key=certs/ca-key.pem \
    -config=certs/config/ca-config.json \
    -profile=default \
    certs/config/consul-csr.json | cfssljson -bare certs/consul


# Do the same for Vault:
cfssl gencert \
    -ca=certs/ca.pem \
    -ca-key=certs/ca-key.pem \
    -config=certs/config/ca-config.json \
    -profile=default \
    certs/config/vault-csr.json | cfssljson -bare certs/vault

# Display the "certs" directory
tree certs/
