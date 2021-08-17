#!/usr/bin/env bash

set -eo pipefail

CONFIG_FILE="configuration.sh"
if [[ ! -f $CONFIG_FILE ]]; then
    echo "File 'configuration.sh' does not exist."
    exit 1
fi

source $CONFIG_FILE

[[ "$DEBUG" == 'true' ]] && set -x

### Check pre-requisite input information ###
missing_variables=()
[[ -z $NAMESPACE ]] && missing_variables+=("NAMESPACE")
[[ -z $CPD_NAMESPACE ]] && missing_variables+=("CPD_NAMESPACE")
[[ -z $CPD_DOMAIN ]] && missing_variables+=("CPD_DOMAIN")
[[ -z $IBM_ENTITLEMENT_KEY ]] && missing_variables+=("IBM_ENTITLEMENT_KEY")
[[ -z $PALANTIR_REGISTRATION_KEY ]] && missing_variables+=("PALANTIR_REGISTRATION_KEY")
[[ -z $STORAGE_CLASS ]] && missing_variables+=("STORAGE_CLASS")
[[ -z $DATA_STORAGE_PATH ]] && missing_variables+=("DATA_STORAGE_PATH")
[[ -z $DATA_STORAGE_ENDPOINT ]] && missing_variables+=("DATA_STORAGE_ENDPOINT")
[[ -z $DATA_STORAGE_ENCRYPTION_PUBLIC_KEY_FILE ]] && missing_variables+=("DATA_STORAGE_ENCRYPTION_PUBLIC_KEY_FILE")
[[ -z $DATA_STORAGE_ENCRYPTION_PRIVATE_KEY_FILE ]] && missing_variables+=("DATA_STORAGE_ENCRYPTION_PRIVATE_KEY_FILE")
[[ -z $DATA_STORAGE_ACCESS_KEY ]] && missing_variables+=("DATA_STORAGE_ACCESS_KEY")
[[ -z $DATA_STORAGE_ACCESS_KEY_SECRET ]] && missing_variables+=("DATA_STORAGE_ACCESS_KEY_SECRET")
[[ -z $PALANTIR_DOCKER_USER ]] && missing_variables+=("PALANTIR_DOCKER_USER")
[[ -z $PALANTIR_DOCKER_PASSWORD ]] && missing_variables+=("PALANTIR_DOCKER_PASSWORD")

if [[ "${#missing_variables[@]}" -ne "0" ]]; then
  echo "One or more required configuration keys were not specified in 'configuration.sh':"
  printf '%s\n' "${missing_variables[@]}"
  exit 1
fi

### Enable firewalls unless overridden
: "${DISABLE_NETWORK_FIREWALLS:=false}"
if [[ $DISABLE_NETWORK_FIREWALLS == "true" ]]; then
  echo "Disabling network firewalls"
fi

### Start installation ###
oc create namespace "$NAMESPACE" --dry-run=client -o yaml | oc apply -f -

oc create secret generic -n "$NAMESPACE" registration-info \
    --from-literal=entitlement-key="$IBM_ENTITLEMENT_KEY" \
    --from-literal=registration-key="$PALANTIR_REGISTRATION_KEY" \
    --dry-run=client -o yaml | oc apply -f -

oc create secret generic -n "$NAMESPACE" data-storage-encryption \
    --from-file=public-key="$DATA_STORAGE_ENCRYPTION_PUBLIC_KEY_FILE" \
    --from-file=private-key="$DATA_STORAGE_ENCRYPTION_PRIVATE_KEY_FILE" \
    --dry-run=client -o yaml | oc apply -f -

oc create secret generic -n "$NAMESPACE" data-storage-creds \
    --from-literal=access-key="$DATA_STORAGE_ACCESS_KEY" \
    --from-literal=access-key-secret="$DATA_STORAGE_ACCESS_KEY_SECRET" \
    --dry-run=client -o yaml | oc apply -f -

if [[ -n $P4CP4D_PROXY_CERTIFICATE_FILE && -n $P4CP4D_PROXY_PRIVATE_KEY_FILE ]]; then
    oc create secret tls -n "$NAMESPACE" proxy-certificate \
      --cert="$P4CP4D_PROXY_CERTIFICATE_FILE" \
      --key="$P4CP4D_PROXY_PRIVATE_KEY_FILE" \
      --dry-run=client -o yaml | oc apply -f -
else
    echo "Using self-signed certificate for P4CP4D proxy"
fi

CUSTOM_CA_CERTIFICATES_DATA=""
if [[ -n $CUSTOM_CA_CERTIFICATES_FILE ]]; then
   echo "Using custom CA certificates"
   CUSTOM_CA_CERTIFICATES_DATA=$(cat $CUSTOM_CA_CERTIFICATES_FILE | base64 -w0)
fi

manifestsDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sed -e "s|#DISABLE_NETWORK_FIREWALLS#|$DISABLE_NETWORK_FIREWALLS|g" \
  -e "s|#STORAGE_CLASS#|$STORAGE_CLASS|g" \
  -e "s|#DATA_STORAGE_PATH#|$DATA_STORAGE_PATH|g" \
  -e "s|#DATA_STORAGE_ENDPOINT#|$DATA_STORAGE_ENDPOINT|g" \
  -e "s|#CPD_NAMESPACE#|$CPD_NAMESPACE|g" \
  -e "s|#CPD_DOMAIN#|$CPD_DOMAIN|g" \
  -e "s|#CUSTOM_CA_CERTIFICATES_DATA#|$CUSTOM_CA_CERTIFICATES_DATA|g" \
  "$manifestsDir"/userconfig.yaml | oc apply -n "$NAMESPACE" -f -

sed -e "s|#NAMESPACE#|$NAMESPACE|g" "$manifestsDir"/rbac.yaml | oc apply -n "$NAMESPACE" -f -

oc create secret -n "$NAMESPACE" docker-registry palantir-ext-creds \
    --docker-server docker.external.palantir.build \
    --docker-username "$PALANTIR_DOCKER_USER" \
    --docker-password "$PALANTIR_DOCKER_PASSWORD" \
    --dry-run=client -o yaml | oc apply -f -

oc patch serviceaccount palantir-operator -n "$NAMESPACE" -p '{"imagePullSecrets": [{"name": "palantir-ext-creds"}]}'

oc apply -n "$NAMESPACE" -f "$manifestsDir"/configmap.yaml
oc apply -n "$NAMESPACE" -f "$manifestsDir"/operator.yaml

echo "Installation complete!"
