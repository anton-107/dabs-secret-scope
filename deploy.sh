#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Default values - these can be overridden by .env file or environment variables
DEFAULT_DATABRICKS_CLI="databricks"
DEFAULT_DATABRICKS_PROFILE="DEFAULT" # A sensible default if nothing else is set

# Source .env file if it exists
if [ -f .env ]; then
  # shellcheck source=.env
  source .env
fi

# Use values from .env or environment variables, with script defaults as fallback
DATABRICKS_CLI="${DATABRICKS_CLI:-$DEFAULT_DATABRICKS_CLI}"
# For DATABRICKS_PROFILE, we allow an external env var to override .env,
# then .env to override script default.
DATABRICKS_PROFILE="${DATABRICKS_PROFILE_ENV:-${DATABRICKS_PROFILE:-$DEFAULT_DATABRICKS_PROFILE}}"

BUNDLE_FILE="databricks.yml"

# --- Helper Functions ---
log_info() {
  echo "[INFO] $1"
}

log_error() {
  echo "[ERROR] $1" >&2
}

confirm_action() {
  while true; do
    read -r -p "$1 [y/N]: " response
    case "$response" in
      [yY][eE][sS]|[yY])
        return 0
        ;;
      [nN][oO]|[nN]|"")
        return 1
        ;;
      *)
        echo "Invalid input. Please answer 'y' or 'n'."
        ;;
    esac
  done
}

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

# 3. Deploy to 'prod' target (with confirmation)
log_info "Preparing to deploy bundle to 'prod' target (CLI: ${DATABRICKS_CLI}, Profile: ${DATABRICKS_PROFILE})..."
if confirm_action "Are you sure you want to deploy to the 'prod' target?"; then
  log_info "Deploying bundle to 'prod' target (CLI: ${DATABRICKS_CLI}, Profile: ${DATABRICKS_PROFILE})..."
  $DATABRICKS_CLI bundle deploy -t prod --profile "${DATABRICKS_PROFILE}"
  if [ $? -ne 0 ]; then
    log_error "Deployment to 'prod' target failed."
    exit 1
  fi
  log_info "Successfully deployed to 'prod' target."
else
  log_info "Deployment to 'prod' target was cancelled by the user."
fi

log_info "Bundle deployment script finished."