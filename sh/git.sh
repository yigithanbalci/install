#!/usr/bin/env bash
#
# Git Tools Installation
# Installs: gh (GitHub CLI), glab (GitLab CLI)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Installing Git Tools..."

install_gh() {
  if is_installed gh; then return 0; fi
  if ! confirm_install "GitHub CLI (gh)"; then return 0; fi
  
  case "$OS" in
    macos)
      pkg_install gh
      ;;
    ubuntu)
      # Official GitHub CLI installation
      (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) &&
        sudo mkdir -p -m 755 /etc/apt/keyrings &&
        out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg &&
        cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
        sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
        sudo apt update &&
        sudo apt install gh -y
      ;;
    arch)
      pkg_install gh
      ;;
    *)
      log_error "Unsupported OS for GitHub CLI"
      return 1
      ;;
  esac
  
  log_success "GitHub CLI installed"
}

install_glab() {
  if is_installed glab; then return 0; fi
  if ! confirm_install "GitLab CLI (glab)"; then return 0; fi
  
  case "$OS" in
    macos)
      pkg_install glab
      ;;
    ubuntu)
      pkg_install glab || {
        log_warning "glab not available in default repos. Install manually if needed."
        return 1
      }
      ;;
    arch)
      pkg_install glab
      ;;
    *)
      log_error "Unsupported OS for GitLab CLI"
      return 1
      ;;
  esac
  
  log_success "GitLab CLI installed"
}

# Main installation
main() {
  local tools=(
    "gh"
    "glab"
  )
  
  for tool in "${tools[@]}"; do
    "install_$tool" || log_warning "Failed to install $tool"
  done
  
  log_success "Git tools installation complete!"
}

main
