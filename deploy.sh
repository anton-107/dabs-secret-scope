#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Source common configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# --- Main Script ---

# 1. Validate the bundle configuration
log_info "Validating Databricks bundle configuration from ${BUNDLE_FILE} using profile ${DATABRICKS_PROFILE}..."
$DATABRICKS_CLI bundle validate --profile "${DATABRICKS_PROFILE}"
if [ $? -ne 0 ]; then
  log_error "Bundle validation failed. Please check your ${BUNDLE_FILE}."
  exit 1
fi
log_info "Bundle validation successful (CLI: ${DATABRICKS_CLI}, Profile: ${DATABRICKS_PROFILE})."

# 2. Deploy to 'dev' target
log_info "Deploying bundle to 'dev' target (CLI: ${DATABRICKS_CLI}, Profile: ${DATABRICKS_PROFILE})..."
$DATABRICKS_CLI bundle deploy -t dev --profile "${DATABRICKS_PROFILE}"
if [ $? -ne 0 ]; then
  log_error "Deployment to 'dev' target failed."
  exit 1
fi
log_info "Successfully deployed to 'dev' target."

log_info "Bundle deployment script finished."
