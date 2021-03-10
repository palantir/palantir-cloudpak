#!/bin/bash

set -euo pipefail

echo "Running for namespace: $NAMESPACE and CPD namespace: $CPD_NAMESPACE"

echo "Cleaning stale workspace if it exists..."
rm -rf ./cpd-cli-workspace

if [[ ! -f "./override.yaml" ]]; then
    echo "Please define overrides in a file called override.yaml in the 'case' directory. You can use modules/palantir-operator/x86_64/1.0.0/install-override.yaml as an example."
    exit
fi

echo "Serving up our CASE assembly..."
python3 -m http.server 8000 &> /dev/null &
server_pid=$!

cleanup() {
  kill $server_pid
  exit
}

trap cleanup SIGHUP SIGINT SIGTERM EXIT

install() {
  echo "Running adm install for $NAMESPACE"
  ./cpd-cli/cpd-cli adm \
        --repo ./repo.yaml \
        --assembly palantir-cloudpak \
        --download-path ./cpd-cli-workspace \
        --namespace $CPD_NAMESPACE \
        --tether-to $NAMESPACE \
        --apply \
        --verbose

  echo "Running install for $NAMESPACE"
  ./cpd-cli/cpd-cli install \
        --repo ./repo.yaml \
        --assembly palantir-cloudpak \
        --download-path ./cpd-cli-workspace \
        --override ./override.yaml \
        --namespace $CPD_NAMESPACE \
        --tether-to $NAMESPACE \
        --instance $NAMESPACE \
        --storageclass $STORAGE_CLASS \
        --verbose

#   echo "Completed install for $NAMESPACE"
#    oc create secret -n $NAMESPACE docker-registry palantir-ext-creds --docker-server docker.external.palantir.build --docker-username "$DOCKER_USERNAME" --docker-password "$DOCKER_PASSWORD"
#    oc patch serviceaccount palantir-operator -n $NAMESPACE -p '{"imagePullSecrets": [{"name": "palantir-ext-creds"}]}'
#   oc delete po -n $NAMESPACE -l app.kubernetes.io/instance=palantir-operator
}

uninstall() {
    echo "Uninstalling from $NAMESPACE"
    ./cpd-cli/cpd-cli uninstall \
        --assembly palantir-cloudpak \
        --namespace $CPD_NAMESPACE \
        --instance $NAMESPACE \
        --verbose
    oc delete namespace $NAMESPACE
}

action=${1:-install}
if [[ $action == "install" ]]; then
    install
elif [[ $action == "uninstall" ]]; then
    uninstall
else
    echo "Error: '$action' is not a valid action. Specify one of 'install' or 'uninstall'"
fi

