#!/usr/bin/env bash
set -x

podVault="$(kubectl get pod -l app=vault -o jsonpath='{.items[0].metadata.name}')"

function portForward() {
    podListener="$1"
    echo "All done! Forwarding port 8200..."
    {
        kubectl port-forward "$podListener" 8200:8200&
    } > /dev/null
}

kubectl logs "$podVault" vault

portForward "$podVault"

# statefulset
# Capture all pods of labeled $myApp
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
