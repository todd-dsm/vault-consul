#!/usr/bin/env bash
#  PURPOSE: auto-initialize and unseal vault
# -----------------------------------------------------------------------------
#  PREREQS: a)
#           b)
#           c)
# -----------------------------------------------------------------------------
#  EXECUTE:
# -----------------------------------------------------------------------------
#     TODO: 1) Fix expansion of 'example'
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#  CREATED: 2018/09/00
# -----------------------------------------------------------------------------
set -x

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff

# Data Files
theJelly='/tmp/jelly.out'


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
### Export the Root Token
###---
function getToken() {
    export  ROOT_TOKEN="$(grep 'Root' "$theJelly" | awk '{print $4}')"
    export VAULT_TOKEN="$(grep 'Root' "$theJelly" | awk '{print $4}')"
}

###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Initialize
###   * NO NEED with the Bonzai Operator
###---
vault operator init  2>&1 | tee "$theJelly"


###---
### Export the Root Token
###---
getToken "$theJelly"


###---
### Unseal
###---
printf '%s\n' "Unsealing the Vault..."
while read -r unsealKey; do
    vault operator unseal "$unsealKey"
done <<< "$(awk '1; NR == 3 { exit }' $theJelly | cut -d' ' -f4)"


###---
### Export to the env
###---
printf '%s\n' """

               *** EXPORT TO THE ENVIRONMENT ***

    export  ROOT_TOKEN=$ROOT_TOKEN
    export VAULT_TOKEN=$VAULT_TOKEN
    export VAULT_CACERT="certs/ca.pem"

"""



###---
### REQ
###---


###---
### REQ
###---


###---
### fin~
###---
exit 0
