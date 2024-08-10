#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <instance_name> <key=value> [--dry-run]"
  exit 1
fi

INSTANCE_NAME=$1
KEY_VALUE=$2
DRY_RUN=$3
KEY=$(echo $KEY_VALUE | cut -d'=' -f1)
VALUE=$(echo $KEY_VALUE | cut -d'=' -f2)

# Ensure KEY and VALUE are set correctly
if [ -z "$KEY" ] || [ -z "$VALUE" ]; then
  echo "Invalid key=value format. Please use key=value."
  exit 1
fi

# Get the list of pod names based on the instance name
PODS=$(kubectl get pods -o=jsonpath="{.items[?(@.metadata.labels.instance=='$INSTANCE_NAME')].metadata.name}")

# Check if any pods are found
if [ -z "$PODS" ]; then
  echo "No pods found with instance name: $INSTANCE_NAME"
  exit 1
fi

# Loop through each pod and update the podname tag
for POD in $PODS; do
  echo "Updating pod $POD with $KEY=$VALUE"
  if [ "$DRY_RUN" == "--dry-run" ]; then
    echo "Dry run: kubectl label pod $POD $KEY=$VALUE --overwrite"
  else
    kubectl label pod $POD $KEY=$VALUE --overwrite
  fi
done

echo "Update complete."
