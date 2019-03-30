#!/usr/bin/env bash
set -x

confDir='./kubes'
vaultDir="$confDir/vault"


function portForward() {
    podListener="$1"
    echo "All done! Forwarding port 8200..."
    {
        kubectl port-forward "$podListener" 8200:8200&
    } > /dev/null
}


# Vault
echo "Creating a Secret to store the Vault TLS certificates..."

kubectl create secret generic vault \
    --from-file=certs/ca.pem \
    --from-file=certs/vault.pem \
    --from-file=certs/vault-key.pem


echo "Storing the Vault config in a ConfigMap..."

kubectl create configmap vault --from-file="$vaultDir/config.json"


echo "Creating the Vault Service..."

kubectl create -f "$vaultDir/service.yaml"

echo "Creating the Vault Deployment..."
kubectl apply -f "$vaultDir/deployment.yaml"

# status check
if ! kubectl wait --for=condition=ready pod -l app=vault --timeout=60s; then
    echo "something is hosed, I'm out"
else
    echo "Vault appears to be all clear!"
fi



# get pod name
podVault="$(kubectl get pod -l app=vault -o jsonpath='{.items[0].metadata.name}')"
kubectl logs "$podVault" vault

portForward "$podVault"

# statefulset: Capture all pods of labeled $myApp
#ssPODS="$(kubectl get pods -l app=vault -o go-template --template \
#    '{{range.items}}{{.metadata.name}}{{"\n"}}{{end}}')"
#
#
## print the first $i array elements up to $myCount
#myCount="$(wc -w <<< "$ssPODS")"
#printf '\n\n%s\n' "Display status of each pod..."
#for (( i = 0; i < "$myCount"; i++ )); do
#    for pod in ${ssPODS[$i]}; do
#        STATUS=$(kubectl get pods "$pod" -o jsonpath="{.status.phase}")
#        printf '%s\n\n' "  $pod is $STATUS"
#        continue
#    done
#done
#
#echo "All done! Forwarding port 8200..."
#{
#    kubectl port-forward 'vault-0' 8200:8200&
#} > /dev/null

