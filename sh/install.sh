#!/usr/bin/env bash
#
# Unified Installation Orchestrator for Unix-based Systems
#
# Three modes of operation:
#   1. Config Mode (--use-config)    - Use config.sh for all decisions
#   2. Interactive Mode (default)    - Prompt for each category/tool
#   3. CLI Arguments Mode            - Install specific categories from args
#
# Usage:
#   ./install.sh                           # Interactive mode
#   ./install.sh --use-config              # Config-based mode
#   ./install.sh --all                     # Install everything
#   ./install.sh cli langs                 # Install specific categories
#   ./install.sh --use-config --exclude devops  # Config mode with overrides
#   ./install.sh --dry-run cli             # Preview installation
#   ./install.sh --list                    # List all available categories
#
# Environment variables:
#   DEV_ENV                  - Path to devenv repository (auto-detected)
#   INSTALL_NONINTERACTIVE=1 - Skip all prompts, use defaults

set -euo pipefail

# Auto-detect script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DEV_ENV="${DEV_ENV:-$(dirname "$SCRIPT_DIR")}"

# Configuration
USE_CONFIG=0
DRY_RUN=0
INTERACTIVE=1
INSTALL_ALL=0
LIST_ONLY=0
EXCLUDE_CATEGORIES=()
ONLY_CATEGORIES=()

# Color output
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color
else
  RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_dry() { echo -e "${YELLOW}[DRY-RUN]${NC} $*"; }

usage() {
  cat <<EOF
Unified Installation Orchestrator for Unix-based Systems

USAGE:
  $(basename "$0") [OPTIONS] [CATEGORIES...]

MODES:
  1. Config Mode    - Use config.sh for decisions (--use-config)
  2. Interactive    - Prompt for each tool (default, no args)
  3. CLI Arguments  - Install specific categories from arguments

OPTIONS:
  -h, --help           Show this help message
  -l, --list          List all available installation categories
  -c, --use-config    Use config.sh for all installation decisions
  -a, --all           Install all categories
  -e, --exclude       Exclude categories (can be used multiple times)
  -o, --only          Only install specified categories (config mode only)
  -d, --dry-run       Show what would be installed without actually installing
  -i, --interactive   Enable interactive mode (default)
  -y, --yes           Non-interactive mode, use defaults

CATEGORIES:
  cli                 CLI tools (fzf, ripgrep, bat, eza, etc.)
  langs               Programming languages (rust, go, node, etc.)
  editors             Text editors (neovim, emacs, zed)
  shells              Shell environments (fish, zsh)
  terminals           Terminal emulators (wezterm, kitty, ghostty)
  terminal-tools      Terminal programs (tmux, lazygit, yazi, etc.)
  devops              DevOps tools (docker, kubernetes, colima)
  build               Build tools (cmake, make)
  shell-utils         Shell utilities (direnv, doppler, fastfetch)
  ai                  AI tools (copilot-cli, claude)
  git                 Git tools (gh, glab)
  wm                  Window managers (aerospace, hyprland)

EXAMPLES:
  $(basename "$0")                           # Interactive mode
  $(basename "$0") --use-config              # Config-based (no prompts)
  $(basename "$0") --all                     # Install everything
  $(basename "$0") cli langs                 # Install CLI tools and languages
  $(basename "$0") --use-config -e devops    # Config mode, exclude devops
  $(basename "$0") --use-config -o cli       # Config mode, only CLI
  $(basename "$0") -e docker -e rust         # Install all except docker and rust
  $(basename "$0") --dry-run cli             # Preview CLI tools installation

CONFIG MODE PRIORITY:
  1. CLI flags (--exclude, --only) override config
  2. Config file (config.sh) provides defaults
  3. All settings fallback to interactive prompts

EOF
}

list_categories() {
  log_info "Available installation categories:"
  echo ""
  echo "  cli            - Modern CLI tools"
  echo "  langs          - Programming language toolchains"
  echo "  editors        - Text editors and IDEs"
  echo "  shells         - Shell environments"
  echo "  terminals      - Terminal emulators"
  echo "  terminal-tools - Terminal-based programs"
  echo "  devops         - Container and orchestration tools"
  echo "  build          - Build systems and tools"
  echo "  shell-utils    - Shell enhancement utilities"
  echo "  ai             - AI and ML command-line tools"
  echo "  git            - Git CLI tools"
  echo "  wm             - Window managers"
  echo ""
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        usage
        exit 0
        ;;
      -l|--list)
        LIST_ONLY=1
        shift
        ;;
      -c|--use-config|--config)
        USE_CONFIG=1
        INTERACTIVE=0
        shift
        ;;
      -a|--all)
        INSTALL_ALL=1
        INTERACTIVE=0
        shift
        ;;
      -e|--exclude)
        EXCLUDE_CATEGORIES+=("$2")
        shift 2
        ;;
      -o|--only)
        ONLY_CATEGORIES+=("$2")
        shift 2
        ;;
      -d|--dry-run)
        DRY_RUN=1
        shift
        ;;
      -i|--interactive)
        INTERACTIVE=1
        shift
        ;;
      -y|--yes)
        INTERACTIVE=0
        export INSTALL_NONINTERACTIVE=1
        shift
        ;;
      -*)
        log_error "Unknown option: $1"
        usage
        exit 1
        ;;
      *)
        # Category argument
        ONLY_CATEGORIES+=("$1")
        INTERACTIVE=0
        shift
        ;;
    esac
  done
}

load_config() {
  local config_file="$SCRIPT_DIR/config.sh"
  
  if [[ ! -f "$config_file" ]]; then
    log_error "Config file not found: $config_file"
    log_info "Please create config.sh or run without --use-config"
    exit 1
  fi
  
  log_info "Loading configuration from $config_file"
  
  # Source config
  # shellcheck source=./config.sh
  if ! source "$config_file"; then
    log_error "Failed to source config file"
    exit 1
  fi
  
  # Export config variables
  export_config
  
  if [[ "${INSTALL_CONFIG_LOADED:-0}" != "1" ]]; then
    log_error "Failed to load configuration"
    exit 1
  fi
  
  log_success "Configuration loaded successfully"
}

apply_config_overrides() {
  local all_categories=(cli langs editors shells terminals terminal-tools devops build shell-utils ai git wm)
  
  # If --only or categories specified, override to install only those
  if [[ ${#ONLY_CATEGORIES[@]} -gt 0 ]]; then
    log_info "Overriding config: only installing ${ONLY_CATEGORIES[*]}"
    
    # Disable all categories first
    for category in "${all_categories[@]}"; do
      local cat_normalized
      cat_normalized=$(echo "$category" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
      local var_name="INSTALL_CATEGORY_${cat_normalized}"
      export "$var_name=0"
    done
    
    # Enable only specified categories
    for category in "${ONLY_CATEGORIES[@]}"; do
      local cat_normalized
      cat_normalized=$(echo "$category" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
      local var_name="INSTALL_CATEGORY_${cat_normalized}"
      export "$var_name=1"
      log_info "  ✓ Enabled: $category"
    done
  fi
  
  # If --exclude specified, disable those categories
  if [[ ${#EXCLUDE_CATEGORIES[@]} -gt 0 ]]; then
    log_info "Excluding: ${EXCLUDE_CATEGORIES[*]}"
    for category in "${EXCLUDE_CATEGORIES[@]}"; do
      local cat_normalized
      cat_normalized=$(echo "$category" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
      local var_name="INSTALL_CATEGORY_${cat_normalized}"
      export "$var_name=0"
      log_info "  ✗ Disabled: $category"
    done
  fi
}

get_categories_to_install() {
  local all_categories=(cli langs editors shells terminals terminal-tools devops build shell-utils ai git wm)
  local categories=()
  
  if [[ $USE_CONFIG -eq 1 ]]; then
    # Config mode: check which categories are enabled
    for category in "${all_categories[@]}"; do
      local cat_normalized
      cat_normalized=$(echo "$category" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
      local var_name="INSTALL_CATEGORY_${cat_normalized}"
      
      if [[ "${!var_name:-0}" == "1" ]]; then
        categories+=("$category")
      fi
    done
  elif [[ ${#ONLY_CATEGORIES[@]} -gt 0 ]]; then
    # Specific categories specified
    categories=("${ONLY_CATEGORIES[@]}")
  elif [[ $INSTALL_ALL -eq 1 ]]; then
    # Install all, minus excludes
    for category in "${all_categories[@]}"; do
      local excluded=0
      for excl in "${EXCLUDE_CATEGORIES[@]}"; do
        if [[ "$category" == "$excl" ]]; then
          excluded=1
          break
        fi
      done
      if [[ $excluded -eq 0 ]]; then
        categories+=("$category")
      fi
    done
  else
    # Interactive mode will handle this later
    categories=("${all_categories[@]}")
  fi
  
  # Apply excludes
  if [[ ${#EXCLUDE_CATEGORIES[@]} -gt 0 ]]; then
    local filtered=()
    for category in "${categories[@]}"; do
      local excluded=0
      for excl in "${EXCLUDE_CATEGORIES[@]}"; do
        if [[ "$category" == "$excl" ]]; then
          excluded=1
          break
        fi
      done
      if [[ $excluded -eq 0 ]]; then
        filtered+=("$category")
      fi
    done
    categories=("${filtered[@]}")
  fi
  
  echo "${categories[@]}"
}

interactive_select() {
  log_info "Interactive Installation Mode"
  echo ""
  list_categories
  echo "Select categories to install (space-separated, or 'all' for everything):"
  read -r selection
  
  if [[ "$selection" == "all" ]]; then
    INSTALL_ALL=1
  else
    # shellcheck disable=SC2206
    ONLY_CATEGORIES=(${selection})
  fi
}

run_install_script() {
  local script="$1"
  local category
  category="$(basename "${script%.sh}")"
  
  if [[ $DRY_RUN -eq 1 ]]; then
    log_dry "Would run: $script"
    return 0
  fi
  
  log_info "Running installation: $category"
  if bash "$script"; then
    log_success "Completed: $category"
    return 0
  else
    log_error "Failed: $category"
    return 1
  fi
}

main() {
  parse_args "$@"
  
  if [[ $LIST_ONLY -eq 1 ]]; then
    list_categories
    exit 0
  fi
  
  # Load config if requested
  if [[ $USE_CONFIG -eq 1 ]]; then
    load_config
    apply_config_overrides
  fi
  
  # Interactive mode
  if [[ $INTERACTIVE -eq 1 ]] && [[ ${#ONLY_CATEGORIES[@]} -eq 0 ]] && [[ $INSTALL_ALL -eq 0 ]]; then
    interactive_select
  fi
  
  # Get categories to install
  local categories_arr
  read -ra categories_arr <<< "$(get_categories_to_install)"
  
  if [[ ${#categories_arr[@]} -eq 0 ]]; then
    log_warning "No categories selected for installation"
    exit 0
  fi
  
  # Build list of scripts to run
  local scripts_to_run=()
  for category in "${categories_arr[@]}"; do
    local script="$SCRIPT_DIR/${category}.sh"
    if [[ -f "$script" ]]; then
      scripts_to_run+=("$script")
    else
      log_warning "Script not found for category: $category"
    fi
  done
  
  if [[ ${#scripts_to_run[@]} -eq 0 ]]; then
    log_warning "No installation scripts matched your criteria"
    exit 0
  fi
  
  # Show summary
  echo ""
  log_info "Installation plan (${#scripts_to_run[@]} categories):"
  for script in "${scripts_to_run[@]}"; do
    echo "  - $(basename "${script%.sh}")"
  done
  echo ""
  
  if [[ $USE_CONFIG -eq 1 ]]; then
    log_info "Mode: Config-based (respecting config.sh settings)"
  elif [[ $INTERACTIVE -eq 1 ]]; then
    log_info "Mode: Interactive (will prompt for each tool)"
  else
    log_info "Mode: CLI arguments"
  fi
  echo ""
  
  # Confirm if not in non-interactive mode
  if [[ "${INSTALL_NONINTERACTIVE:-0}" != "1" ]] && [[ $DRY_RUN -eq 0 ]]; then
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log_info "Installation cancelled"
      exit 0
    fi
  fi
  
  # Run installations
  local failed=0
  for script in "${scripts_to_run[@]}"; do
    if ! run_install_script "$script"; then
      ((failed++))
    fi
  done
  
  echo ""
  if [[ $failed -eq 0 ]]; then
    log_success "All installations completed successfully!"
  else
    log_error "$failed installation(s) failed"
    exit 1
  fi
}

main "$@"
