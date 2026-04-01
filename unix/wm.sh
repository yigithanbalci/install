#!/usr/bin/env bash
#
# Window Manager Installation
# Installs: AeroSpace (macOS), Hyprland components (Arch Linux)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Installing Window Managers..."

install_aerospace() {
  if is_installed aerospace; then return 0; fi
  
  case "$OS" in
    macos)
      # Install AeroSpace from tap
      brew install --cask nikitabobko/tap/aerospace
      log_success "AeroSpace installed"
      ;;
    *)
      log_warning "AeroSpace is only available for macOS"
      return 1
      ;;
  esac
}

install_yabai() {
  if is_installed yabai; then return 0; fi
  
  case "$OS" in
    macos)
      # Commented out in original but included as option
      brew install koekeishiya/formulae/yabai
      log_success "yabai installed (requires additional configuration)"
      ;;
    *)
      log_warning "yabai is only available for macOS"
      return 1
      ;;
  esac
}

install_skhd() {
  if is_installed skhd; then return 0; fi
  
  case "$OS" in
    macos)
      # Commented out in original but included as option
      brew install koekeishiya/formulae/skhd
      log_success "skhd installed (requires additional configuration)"
      ;;
    *)
      log_warning "skhd is only available for macOS"
      return 1
      ;;
  esac
}

install_hyprland() {
  
  case "$OS" in
    arch)
      log_info "Installing Hyprland components..."
      
      # Check if Hyprland is already installed
      if ! is_installed Hyprland; then
        log_warning "Hyprland not detected. It may already be installed with your Arch setup."
      fi
      
      # Install Hyprland components
      pkg_install waybar
      pkg_install hyprpaper
      pkg_install hyprlock
      
      log_success "Hyprland components installed"
      ;;
    *)
      log_warning "Hyprland is only available for Arch Linux"
      return 1
      ;;
  esac
}

# Main installation
main() {
  case "$OS" in
    macos)
      log_info "Installing macOS window managers..."
      
      # Install based on config
      if confirm_install "aerospace" "wm"; then
        install_aerospace || log_warning "Failed to install aerospace"
      fi
      
      if confirm_install "yabai" "wm"; then
        install_yabai || log_warning "Failed to install yabai"
      fi
      
      if confirm_install "skhd" "wm"; then
        install_skhd || log_warning "Failed to install skhd"
      fi
      ;;
    arch)
      log_info "Installing Linux window manager components..."
      
      if confirm_install "hyprland" "wm"; then
        install_hyprland || log_warning "Failed to install Hyprland components"
      fi
      ;;
    ubuntu)
      log_warning "No window managers configured for Ubuntu"
      ;;
    *)
      log_error "Unsupported OS for window managers"
      return 1
      ;;
  esac
  
  log_success "Window manager installation complete!"
}

main
