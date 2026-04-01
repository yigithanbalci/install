#!/usr/bin/env bash
#
# Unix Installation Entry Point
# Single entry point for all Unix-based installation operations
#
# This script delegates to the actual installer in unix/install.sh,
# passing through all arguments unchanged.
#
# Usage:
#   ./unix.sh                              # Interactive mode
#   ./unix.sh --use-config                 # Config-based mode
#   ./unix.sh cli langs                    # Install specific categories
#   ./unix.sh --use-config -e devops       # Config mode with overrides
#   ./unix.sh --help                       # Show help
#
# See unix/install.sh for full documentation

set -euo pipefail

# Detect script directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER="$REPO_ROOT/unix/install.sh"

# Check if installer exists
if [[ ! -f "$INSTALLER" ]]; then
  echo "Error: Installer not found at $INSTALLER"
  exit 1
fi

# Check if installer is executable
if [[ ! -x "$INSTALLER" ]]; then
  chmod +x "$INSTALLER"
fi

# Pass all arguments to the installer
exec "$INSTALLER" "$@"
