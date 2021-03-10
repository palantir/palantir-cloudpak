#!/bin/bash

set -euo pipefail

if ! [ -x "$(command -v oc)" ]; then
    echo 'Error: oc is not installed. Please install it (you can use "brew install openshift-cli" if you like)'
    exit 1
fi

echo "Checking if logged in..."
if ! oc whoami; then
    echo 'Error: not logged into to an OpenShift cluster. Please login before running this script' 
    exit 1
fi

cd cpd-cli
file="cpd-cli"
if [[ -f "$file" ]]; then
    echo "$file exists. Not downlooading it again"
else
    curl -LO -C- -k https://github.com/IBM/cpd-cli/releases/download/v3.5.2/cpd-cli-darwin-SE-3.5.2.tgz
    tar -xvf cpd-cli-darwin-SE-3.5.2.tgz cpd-cli plugins/ LICENSES/
    rm cpd-cli-darwin-SE-3.5.2.tgz
fi
