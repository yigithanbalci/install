#!/usr/bin/env bash
#
# Window Manager Installation
# Installs: AeroSpace (macOS), Hyprland components (Arch Linux)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

log_info "Installing Window Managers..."

install_aerospace() {
  if is_installed aerospace; then return 0; fi
  if ! confirm_install "AeroSpace (macOS tiling WM)"; then return 0; fi
  
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
  if ! confirm_install "yabai (macOS tiling WM)"; then return 0; fi
  
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
  if ! confirm_install "skhd (macOS hotkey daemon)"; then return 0; fi
  
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

install_hyprland_components() {
  if ! confirm_install "Hyprland components (waybar, hyprpaper, hyprlock)"; then return 0; fi
  
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
      install_aerospace
      
      # Optional: Uncomment if you want to offer yabai/skhd
      # install_yabai
      # install_skhd
      ;;
    arch)
      log_info "Installing Linux window manager components..."
      install_hyprland_components
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
