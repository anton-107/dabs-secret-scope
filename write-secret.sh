#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Source common configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# --- Main Script ---
SECRET_SCOPE_NAME=$($DATABRICKS_CLI bundle summary -o json -p $DATABRICKS_PROFILE | jq -r '.resources.secret_scopes.my_secret_scope.name')

if [ -z "$SECRET_SCOPE_NAME" ]; then
  echo "Error: Failed to get secret scope name. Have you deployed the bundle?" >&2
  exit 1
fi


echo "Writing a sample secret to: ${SECRET_SCOPE_NAME} (profile: ${DATABRICKS_PROFILE})"
$DATABRICKS_CLI secrets put-secret ${SECRET_SCOPE_NAME} example-key --string-value example-value --profile ${DATABRICKS_PROFILE}

echo "Reading the secret back from the secret scope:"
$DATABRICKS_CLI secrets get-secret ${SECRET_SCOPE_NAME} example-key --profile ${DATABRICKS_PROFILE} # | jq -r '.value' | base64 -D