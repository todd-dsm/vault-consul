#!/usr/bin/env bash
set -x

confDir='./kubes'
consulDir="$confDir/consul"

echo "Generating the Gossip encryption key..."

export GOSSIP_ENCRYPTION_KEY=$(consul keygen)


echo "Creating the Consul Secret to store the Gossip key and the TLS certificates..."

kubectl create secret generic consul \
  --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
  --from-file=certs/ca.pem \
  --from-file=certs/consul.pem \
  --from-file=certs/consul-key.pem

echo "Storing the Consul config in a ConfigMap..."

kubectl create configmap consul --from-file="$consulDir/config.json"

echo "Creating the Consul Service..."
# don't wait for services
kubectl create -f "$consulDir/service.yaml"

echo "Creating the Consul StatefulSet..."

kubectl create -f "$consulDir/statefulset.yaml"

# status check
if ! kkubectl wait --for=condition=ready pod -l app=consul --timeout=60s; then
    echo "something is hosed, I'm out"
else
    echo "Consul appears to be all clear!"
fi


