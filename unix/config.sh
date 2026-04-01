#!/usr/bin/env bash
#
# Installation Configuration
# Define which tools and categories to install
#
# Usage:
#   1. Set ENABLED=1 for categories/tools you want
#   2. Set ENABLED=0 for categories/tools you don't want
#   3. Run: ./sh/install.sh --config
#
# The installer will read this config and only install enabled items

set -euo pipefail

# =============================================================================
# CATEGORIES - Enable/disable entire categories
# =============================================================================

# Initialize associative arrays for categories
INSTALL_CATEGORY_CLI=1
INSTALL_CATEGORY_LANGS=1
INSTALL_CATEGORY_EDITORS=1
INSTALL_CATEGORY_SHELLS=1
INSTALL_CATEGORY_TERMINALS=1
INSTALL_CATEGORY_TERMINAL_TOOLS=1
INSTALL_CATEGORY_DEVOPS=0
INSTALL_CATEGORY_BUILD=1
INSTALL_CATEGORY_SHELL_UTILS=1
INSTALL_CATEGORY_AI=1
INSTALL_CATEGORY_GIT=1
INSTALL_CATEGORY_WM=1

# =============================================================================
# CLI TOOLS - Individual tool configuration
# =============================================================================

INSTALL_CLI_RIPGREP=1
INSTALL_CLI_FZF=1
INSTALL_CLI_FD=1
INSTALL_CLI_BAT=1
INSTALL_CLI_EZA=1
INSTALL_CLI_JQ=1
INSTALL_CLI_ZOXIDE=1
INSTALL_CLI_ATUIN=1
INSTALL_CLI_TLDR=1
INSTALL_CLI_STOW=1
INSTALL_CLI_TREE_SITTER=1
INSTALL_CLI_LAZYGIT=1
INSTALL_CLI_TELEVISION=1
INSTALL_CLI_SESH=1
INSTALL_CLI_AWK=1
INSTALL_CLI_CURL=1
INSTALL_CLI_WORKTRUNK=0 # Requires Go

# =============================================================================
# PROGRAMMING LANGUAGES
# =============================================================================

INSTALL_LANG_RUST=1
INSTALL_LANG_GO=1
INSTALL_LANG_NODE=1
INSTALL_LANG_PYTHON=1
INSTALL_LANG_LUA=1
INSTALL_LANG_RUBY=0
INSTALL_LANG_JAVA=0
INSTALL_LANG_DOTNET=0
INSTALL_LANG_ZIG=0
INSTALL_LANG_BUN=1
INSTALL_LANG_DENO=0

# =============================================================================
# TEXT EDITORS
# =============================================================================

INSTALL_EDITOR_NEOVIM=1
INSTALL_EDITOR_EMACS=0
INSTALL_EDITOR_ZED=1
INSTALL_EDITOR_HELIX=0

# =============================================================================
# SHELLS
# =============================================================================

INSTALL_SHELL_FISH=0
INSTALL_SHELL_ZSH=1
INSTALL_SHELL_BASH=1
INSTALL_SHELL_NUSHELL=0

# =============================================================================
# TERMINAL EMULATORS
# =============================================================================

INSTALL_TERMINAL_WEZTERM=1
INSTALL_TERMINAL_KITTY=0
INSTALL_TERMINAL_GHOSTTY=0
INSTALL_TERMINAL_ALACRITTY=0
INSTALL_TERMINAL_ITERM2=0

# =============================================================================
# TERMINAL TOOLS
# =============================================================================

INSTALL_TERMINAL_TOOL_TMUX=1
INSTALL_TERMINAL_TOOL_YAZI=1
INSTALL_TERMINAL_TOOL_LAZYDOCKER=0
INSTALL_TERMINAL_TOOL_BTOP=1
INSTALL_TERMINAL_TOOL_HTOP=1

# =============================================================================
# DEVOPS TOOLS
# =============================================================================

INSTALL_DEVOPS_DOCKER=0
INSTALL_DEVOPS_COLIMA=0
INSTALL_DEVOPS_KUBERNETES=0
INSTALL_DEVOPS_KUBECTL=0
INSTALL_DEVOPS_K9S=0
INSTALL_DEVOPS_TERRAFORM=0
INSTALL_DEVOPS_ANSIBLE=0

# =============================================================================
# BUILD TOOLS
# =============================================================================

INSTALL_BUILD_CMAKE=1
INSTALL_BUILD_MAKE=1
INSTALL_BUILD_NINJA=1
INSTALL_BUILD_MESON=0

# =============================================================================
# SHELL UTILITIES
# =============================================================================

INSTALL_SHELL_UTIL_DIRENV=1
INSTALL_SHELL_UTIL_DOPPLER=0
INSTALL_SHELL_UTIL_FASTFETCH=1
INSTALL_SHELL_UTIL_NEOFETCH=0
INSTALL_SHELL_UTIL_STARSHIP=1

# =============================================================================
# AI TOOLS
# =============================================================================

INSTALL_AI_COPILOT_CLI=1
INSTALL_AI_CLAUDE_CLI=0
INSTALL_AI_AIDER=0

# =============================================================================
# GIT TOOLS
# =============================================================================

INSTALL_GIT_GH=1   # GitHub CLI
INSTALL_GIT_GLAB=1 # GitLab CLI

# =============================================================================
# WINDOW MANAGERS
# =============================================================================

INSTALL_WM_AEROSPACE=1 # macOS tiling WM
INSTALL_WM_YABAI=0     # macOS tiling WM (alternative)
INSTALL_WM_SKHD=0      # macOS hotkey daemon
INSTALL_WM_HYPRLAND=1  # Linux (Arch) - components only

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Check if a category is enabled
is_category_enabled() {
  local category="$1"
  local cat_normalized
  cat_normalized=$(echo "$category" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  local var_name="INSTALL_CATEGORY_${cat_normalized}"

  # Use indirect expansion if available, fallback to eval for POSIX
  local value
  if [ -n "${!var_name+x}" ] 2>/dev/null; then
    value="${!var_name}"
  else
    value=$(eval "echo \"\$${var_name}\"")
  fi

  [ "${value:-0}" = "1" ]
}

# Check if a tool is enabled
is_tool_enabled() {
  local category="$1"
  local tool="$2"

  # First check if category is enabled
  if ! is_category_enabled "$category"; then
    return 1
  fi

  # Then check tool-specific setting
  local cat_normalized
  cat_normalized=$(echo "$category" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  local tool_normalized
  tool_normalized=$(echo "$tool" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  local var_name="INSTALL_${cat_normalized}_${tool_normalized}"

  # Use indirect expansion if available, fallback to eval for POSIX
  local value
  if [ -n "${!var_name+x}" ] 2>/dev/null; then
    value="${!var_name}"
  else
    value=$(eval "echo \"\$${var_name}\"")
  fi

  [ "${value:-0}" = "1" ]
}

# Export all configuration variables
export_config() {
  # Export categories
  export INSTALL_CATEGORY_CLI
  export INSTALL_CATEGORY_LANGS
  export INSTALL_CATEGORY_EDITORS
  export INSTALL_CATEGORY_SHELLS
  export INSTALL_CATEGORY_TERMINALS
  export INSTALL_CATEGORY_TERMINAL_TOOLS
  export INSTALL_CATEGORY_DEVOPS
  export INSTALL_CATEGORY_BUILD
  export INSTALL_CATEGORY_SHELL_UTILS
  export INSTALL_CATEGORY_AI
  export INSTALL_CATEGORY_GIT
  export INSTALL_CATEGORY_WM

  # Export CLI tools
  export INSTALL_CLI_RIPGREP
  export INSTALL_CLI_FZF
  export INSTALL_CLI_FD
  export INSTALL_CLI_BAT
  export INSTALL_CLI_EZA
  export INSTALL_CLI_JQ
  export INSTALL_CLI_ZOXIDE
  export INSTALL_CLI_ATUIN
  export INSTALL_CLI_TLDR
  export INSTALL_CLI_STOW
  export INSTALL_CLI_TREE_SITTER
  export INSTALL_CLI_LAZYGIT
  export INSTALL_CLI_TELEVISION
  export INSTALL_CLI_SESH
  export INSTALL_CLI_AWK
  export INSTALL_CLI_CURL
  export INSTALL_CLI_WORKTRUNK

  # Export languages
  export INSTALL_LANG_RUST
  export INSTALL_LANG_GO
  export INSTALL_LANG_NODE
  export INSTALL_LANG_PYTHON
  export INSTALL_LANG_LUA
  export INSTALL_LANG_RUBY
  export INSTALL_LANG_JAVA
  export INSTALL_LANG_DOTNET
  export INSTALL_LANG_ZIG
  export INSTALL_LANG_BUN
  export INSTALL_LANG_DENO

  # Export editors
  export INSTALL_EDITOR_NEOVIM
  export INSTALL_EDITOR_EMACS
  export INSTALL_EDITOR_ZED
  export INSTALL_EDITOR_HELIX

  # Export shells
  export INSTALL_SHELL_FISH
  export INSTALL_SHELL_ZSH
  export INSTALL_SHELL_BASH
  export INSTALL_SHELL_NUSHELL

  # Export terminals
  export INSTALL_TERMINAL_WEZTERM
  export INSTALL_TERMINAL_KITTY
  export INSTALL_TERMINAL_GHOSTTY
  export INSTALL_TERMINAL_ALACRITTY
  export INSTALL_TERMINAL_ITERM2

  # Export terminal tools
  export INSTALL_TERMINAL_TOOL_TMUX
  export INSTALL_TERMINAL_TOOL_YAZI
  export INSTALL_TERMINAL_TOOL_LAZYDOCKER
  export INSTALL_TERMINAL_TOOL_BTOP
  export INSTALL_TERMINAL_TOOL_HTOP

  # Export devops tools
  export INSTALL_DEVOPS_DOCKER
  export INSTALL_DEVOPS_COLIMA
  export INSTALL_DEVOPS_KUBERNETES
  export INSTALL_DEVOPS_KUBECTL
  export INSTALL_DEVOPS_K9S
  export INSTALL_DEVOPS_TERRAFORM
  export INSTALL_DEVOPS_ANSIBLE

  # Export build tools
  export INSTALL_BUILD_CMAKE
  export INSTALL_BUILD_MAKE
  export INSTALL_BUILD_NINJA
  export INSTALL_BUILD_MESON

  # Export shell utilities
  export INSTALL_SHELL_UTIL_DIRENV
  export INSTALL_SHELL_UTIL_DOPPLER
  export INSTALL_SHELL_UTIL_FASTFETCH
  export INSTALL_SHELL_UTIL_NEOFETCH
  export INSTALL_SHELL_UTIL_STARSHIP

  # Export AI tools
  export INSTALL_AI_COPILOT_CLI
  export INSTALL_AI_CLAUDE_CLI
  export INSTALL_AI_AIDER

  # Export git tools
  export INSTALL_GIT_GH
  export INSTALL_GIT_GLAB

  # Export window managers
  export INSTALL_WM_AEROSPACE
  export INSTALL_WM_YABAI
  export INSTALL_WM_SKHD
  export INSTALL_WM_HYPRLAND

  # Signal that config is loaded
  export INSTALL_CONFIG_LOADED=1
}

# Auto-export if sourced (check if being sourced vs executed)
# In bash, BASH_SOURCE[0] != $0 when sourced
if [ -n "${BASH_VERSION}" ]; then
  if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    export_config
  fi
elif [ "${0##*/}" != "config.sh" ]; then
  # Fallback for other shells
  export_config
fi
