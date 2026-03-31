#!/usr/bin/env bash
#
# Config-based installer wrapper
# Loads config.zsh and runs installations based on config settings
#
# Usage:
#   ./install-with-config.sh              # Use config.zsh settings
#   ./install-with-config.sh --dry-run    # Preview what would be installed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color output
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

DRY_RUN=0

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      cat <<EOF
Config-based Installer

USAGE:
  $(basename "$0") [OPTIONS]

OPTIONS:
  -d, --dry-run    Show what would be installed without installing
  -h, --help       Show this help message

CONFIGURATION:
  Edit sh/config.zsh to enable/disable categories and tools.
  Set values to 1 (enabled) or 0 (disabled).

EXAMPLES:
  $(basename "$0")              # Install based on config
  $(basename "$0") --dry-run    # Preview installation

EOF
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check if config exists
CONFIG_FILE="$SCRIPT_DIR/config.zsh"
if [[ ! -f "$CONFIG_FILE" ]]; then
  log_error "Config file not found: $CONFIG_FILE"
  log_info "Please create config.zsh first"
  exit 1
fi

log_info "Loading configuration from $CONFIG_FILE"

# Source config using zsh
if ! command -v zsh >/dev/null 2>&1; then
  log_error "zsh is required to parse config.zsh"
  exit 1
fi

# Export config variables by running zsh script
eval "$(zsh -c "source '$CONFIG_FILE' && export_config && env | grep '^INSTALL_'")"

if [[ "${INSTALL_CONFIG_LOADED:-0}" != "1" ]]; then
  log_error "Failed to load configuration"
  exit 1
fi

log_success "Configuration loaded successfully"
echo ""

# Determine which categories to install
log_info "Enabled categories:"
categories_to_install=()

for category in cli langs editors shells terminals terminal-tools devops build shell-utils ai git wm; do
  cat_normalized=$(echo "$category" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  var_name="INSTALL_CATEGORY_${cat_normalized}"
  
  if [[ "${!var_name:-0}" == "1" ]]; then
    echo "  ✓ $category"
    categories_to_install+=("$category")
  else
    echo "  ✗ $category (disabled)"
  fi
done

echo ""

if [[ ${#categories_to_install[@]} -eq 0 ]]; then
  log_warning "No categories enabled in config"
  exit 0
fi

if [[ $DRY_RUN -eq 1 ]]; then
  log_info "DRY RUN: Would install ${#categories_to_install[@]} categories"
  exit 0
fi

# Confirm before proceeding
read -p "Proceed with installation? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  log_info "Installation cancelled"
  exit 0
fi

# Run installations
log_info "Starting installations..."
echo ""

export INSTALL_CONFIG_LOADED=1
failed=0

for category in "${categories_to_install[@]}"; do
  script="$SCRIPT_DIR/${category}.sh"
  
  if [[ ! -f "$script" ]]; then
    log_warning "Script not found: $script (skipping)"
    continue
  fi
  
  log_info "Running: $category"
  if bash "$script"; then
    log_success "Completed: $category"
  else
    log_error "Failed: $category"
    ((failed++))
  fi
  echo ""
done

echo ""
if [[ $failed -eq 0 ]]; then
  log_success "All installations completed successfully!"
else
  log_error "$failed installation(s) failed"
  exit 1
fi
