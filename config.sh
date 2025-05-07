#!/bin/bash

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