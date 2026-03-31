#!/usr/bin/env bash
#
# Config-based installer with flag overrides
# Loads config.zsh as defaults, CLI flags override config
#
# Usage:
#   ./install-with-config.sh                    # Use config.zsh settings
#   ./install-with-config.sh cli langs          # Override: only install these
#   ./install-with-config.sh --exclude docker   # Override: exclude docker
#   ./install-with-config.sh --only cli         # Override: only CLI category
#   ./install-with-config.sh --dry-run          # Preview

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
EXCLUDE_CATEGORIES=()
ONLY_CATEGORIES=()
FLAG_OVERRIDE=0

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--dry-run)
      DRY_RUN=1
      shift
      ;;
    -e|--exclude)
      EXCLUDE_CATEGORIES+=("$2")
      FLAG_OVERRIDE=1
      shift 2
      ;;
    -o|--only)
      ONLY_CATEGORIES+=("$2")
      FLAG_OVERRIDE=1
      shift 2
      ;;
    -h|--help)
      cat <<EOF
Config-based Installer with Flag Overrides

USAGE:
  $(basename "$0") [OPTIONS] [CATEGORIES...]

OPTIONS:
  -d, --dry-run          Show what would be installed without installing
  -e, --exclude <cat>    Exclude category (overrides config, can repeat)
  -o, --only <cat>       Only install category (overrides config, can repeat)
  -h, --help             Show this help message

CATEGORIES:
  If specified without flags, only install these categories (overrides config).
  Available: cli, langs, editors, shells, terminals, terminal-tools,
             devops, build, shell-utils, ai, git, wm

CONFIGURATION:
  Config file (sh/config.zsh) sets defaults.
  CLI flags override config settings.

PRIORITY:
  1. CLI flags (--exclude, --only, or category args)
  2. Config file (config.zsh)
  3. Default (install all)

EXAMPLES:
  $(basename "$0")                        # Use config.zsh
  $(basename "$0") cli langs              # Override: only cli and langs
  $(basename "$0") --exclude docker       # Use config but skip docker
  $(basename "$0") --only cli             # Override: only CLI tools
  $(basename "$0") -e devops -e ai        # Exclude multiple categories
  $(basename "$0") --dry-run cli          # Preview CLI installation

EOF
      exit 0
      ;;
    -*)
      log_error "Unknown option: $1"
      exit 1
      ;;
    *)
      # Category name
      ONLY_CATEGORIES+=("$1")
      FLAG_OVERRIDE=1
      shift
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

# Apply flag overrides
if [[ $FLAG_OVERRIDE -eq 1 ]]; then
  log_info "CLI flags detected - overriding config"
  
  # If --only or categories specified, override to install only those
  if [[ ${#ONLY_CATEGORIES[@]} -gt 0 ]]; then
    log_info "Only installing: ${ONLY_CATEGORIES[*]}"
    
    # Disable all categories first
    for category in cli langs editors shells terminals terminal-tools devops build shell-utils ai git wm; do
      cat_normalized=$(echo "$category" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
      var_name="INSTALL_CATEGORY_${cat_normalized}"
      export "$var_name=0"
    done
    
    # Enable only specified categories
    for category in "${ONLY_CATEGORIES[@]}"; do
      cat_normalized=$(echo "$category" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
      var_name="INSTALL_CATEGORY_${cat_normalized}"
      export "$var_name=1"
      log_info "  ✓ Enabled: $category"
    done
  fi
  
  # If --exclude specified, disable those categories
  if [[ ${#EXCLUDE_CATEGORIES[@]} -gt 0 ]]; then
    log_info "Excluding: ${EXCLUDE_CATEGORIES[*]}"
    for category in "${EXCLUDE_CATEGORIES[@]}"; do
      cat_normalized=$(echo "$category" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
      var_name="INSTALL_CATEGORY_${cat_normalized}"
      export "$var_name=0"
      log_info "  ✗ Disabled: $category"
    done
  fi
fi

echo ""

# Determine which categories to install (after flag overrides)
log_info "Final installation plan:"
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
  log_warning "No categories enabled"
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
