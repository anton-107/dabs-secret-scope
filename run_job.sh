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


echo "Starting an example job run (profile: ${DATABRICKS_PROFILE})"
$DATABRICKS_CLI bundle run example_python_job --profile ${DATABRICKS_PROFILE}