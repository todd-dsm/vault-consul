#!/usr/bin/env bash
set -x


echo "Generating the Gossip encryption key..."

export GOSSIP_ENCRYPTION_KEY=$(consul keygen)


echo "Creating the Consul Secret to store the Gossip key and the TLS certificates..."

kubectl create secret generic consul \
  --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
  --from-file=certs/ca.pem \
  --from-file=certs/consul.pem \
  --from-file=certs/consul-key.pem


echo "Storing the Consul config in a ConfigMap..."

kubectl create configmap consul --from-file=consul/config.json


echo "Creating the Consul Service..."

kubectl create -f consul/service.yaml


echo "Creating the Consul StatefulSet..."

kubectl create -f consul/statefulset.yaml

echo "Creating a Secret to store the Vault TLS certificates..."

kubectl create secret generic vault \
    --from-file=certs/ca.pem \
    --from-file=certs/vault.pem \
    --from-file=certs/vault-key.pem


echo "Storing the Vault config in a ConfigMap..."

kubectl create configmap vault --from-file=vault/config.json


echo "Creating the Vault Service..."

kubectl create -f vault/service.yaml


echo "Creating the Vault Deployment..."

kubectl apply -f vault/statefulset.yaml
sleep 10
#kubectl apply -f vault/deployment.yaml


# Capture all pods of labeled $myApp
ssPODS="$(kubectl get pods -l app=vault -o go-template --template \
    '{{range.items}}{{.metadata.name}}{{"\n"}}{{end}}')"


# print the first $i array elements up to $myCount
myCount="$(wc -w <<< "$ssPODS")"
printf '\n\n%s\n' "Display status of each pod..."
for (( i = 0; i < "$myCount"; i++ )); do
    for pod in ${ssPODS[$i]}; do
        STATUS=$(kubectl get pods "$pod" -o jsonpath="{.status.phase}")
        printf '%s\n\n' "  $pod is $STATUS"
        continue
    done
done

echo "All done! Forwarding port 8200..."
{
    kubectl port-forward 'vault-0' 8200:8200&
} > /dev/null
