#!/usr/bin/env zsh
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

# =============================================================================
# CATEGORIES - Enable/disable entire categories
# =============================================================================

typeset -A INSTALL_CATEGORIES
INSTALL_CATEGORIES=(
  [cli]=1              # Modern CLI tools (ripgrep, fzf, bat, eza, etc.)
  [langs]=1            # Programming languages (rust, go, node, python, etc.)
  [editors]=1          # Text editors (neovim, emacs, zed)
  [shells]=1           # Shell environments (fish, zsh)
  [terminals]=1        # Terminal emulators (wezterm, kitty, ghostty)
  [terminal-tools]=1   # Terminal programs (tmux, lazygit, yazi)
  [devops]=0           # DevOps tools (docker, kubernetes, colima)
  [build]=1            # Build tools (cmake, make)
  [shell-utils]=1      # Shell utilities (direnv, doppler, fastfetch)
  [ai]=1               # AI tools (copilot-cli, claude)
  [git]=1              # Git tools (gh, glab)
  [wm]=1               # Window managers (aerospace, hyprland)
)

# =============================================================================
# CLI TOOLS - Individual tool configuration
# =============================================================================

typeset -A CLI_TOOLS
CLI_TOOLS=(
  [ripgrep]=1
  [fzf]=1
  [fd]=1
  [bat]=1
  [eza]=1
  [jq]=1
  [zoxide]=1
  [atuin]=1
  [tldr]=1
  [stow]=1
  [tree-sitter]=1
  [lazygit]=1
  [television]=1
  [sesh]=1
  [awk]=1
  [curl]=1
  [worktrunk]=0  # Requires Go
)

# =============================================================================
# PROGRAMMING LANGUAGES
# =============================================================================

typeset -A LANGS
LANGS=(
  [rust]=1
  [go]=1
  [node]=1
  [python]=1
  [lua]=1
  [ruby]=0
  [java]=0
  [dotnet]=0
  [zig]=0
  [bun]=1
  [deno]=0
)

# =============================================================================
# TEXT EDITORS
# =============================================================================

typeset -A EDITORS
EDITORS=(
  [neovim]=1
  [emacs]=0
  [zed]=1
  [helix]=0
)

# =============================================================================
# SHELLS
# =============================================================================

typeset -A SHELLS
SHELLS=(
  [fish]=0
  [zsh]=1
  [bash]=1
  [nushell]=0
)

# =============================================================================
# TERMINAL EMULATORS
# =============================================================================

typeset -A TERMINALS
TERMINALS=(
  [wezterm]=1
  [kitty]=0
  [ghostty]=0
  [alacritty]=0
  [iterm2]=0
)

# =============================================================================
# TERMINAL TOOLS
# =============================================================================

typeset -A TERMINAL_TOOLS
TERMINAL_TOOLS=(
  [tmux]=1
  [yazi]=1
  [lazydocker]=0
  [btop]=1
  [htop]=1
)

# =============================================================================
# DEVOPS TOOLS
# =============================================================================

typeset -A DEVOPS_TOOLS
DEVOPS_TOOLS=(
  [docker]=0
  [colima]=0
  [kubernetes]=0
  [kubectl]=0
  [k9s]=0
  [terraform]=0
  [ansible]=0
)

# =============================================================================
# BUILD TOOLS
# =============================================================================

typeset -A BUILD_TOOLS
BUILD_TOOLS=(
  [cmake]=1
  [make]=1
  [ninja]=1
  [meson]=0
)

# =============================================================================
# SHELL UTILITIES
# =============================================================================

typeset -A SHELL_UTILS
SHELL_UTILS=(
  [direnv]=1
  [doppler]=0
  [fastfetch]=1
  [neofetch]=0
  [starship]=1
)

# =============================================================================
# AI TOOLS
# =============================================================================

typeset -A AI_TOOLS
AI_TOOLS=(
  [copilot-cli]=1
  [claude-cli]=0
  [aider]=0
)

# =============================================================================
# GIT TOOLS
# =============================================================================

typeset -A GIT_TOOLS
GIT_TOOLS=(
  [gh]=1        # GitHub CLI
  [glab]=1      # GitLab CLI
)

# =============================================================================
# WINDOW MANAGERS
# =============================================================================

typeset -A WM_TOOLS
WM_TOOLS=(
  [aerospace]=1      # macOS tiling WM
  [yabai]=0          # macOS tiling WM (alternative)
  [skhd]=0           # macOS hotkey daemon
  [hyprland]=1       # Linux (Arch) - components only
)

# =============================================================================
# HELPER FUNCTIONS - Do not modify below unless you know what you're doing
# =============================================================================

# Check if a category is enabled
is_category_enabled() {
  local category="$1"
  [[ ${INSTALL_CATEGORIES[$category]:-0} -eq 1 ]]
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
  local var_name="${category}_TOOLS"
  local -A tools
  eval "tools=(\"\${(@kv)${var_name}}\")"
  
  [[ ${tools[$tool]:-0} -eq 1 ]]
}

# Export for use in bash scripts
export_config() {
  # Export categories (convert hyphens to underscores)
  for category tool in "${(@kv)INSTALL_CATEGORIES}"; do
    local cat_normalized="${category:u}"
    cat_normalized="${cat_normalized//-/_}"  # Replace hyphens with underscores
    export "INSTALL_CATEGORY_${cat_normalized}=$tool"
  done
  
  # Export all tool configs (convert hyphens to underscores)
  for tool enabled in "${(@kv)CLI_TOOLS}"; do
    local tool_normalized="${tool:u}"
    tool_normalized="${tool_normalized//-/_}"
    export "INSTALL_CLI_${tool_normalized}=$enabled"
  done
  
  for tool enabled in "${(@kv)LANGS}"; do
    local tool_normalized="${tool:u}"
    tool_normalized="${tool_normalized//-/_}"
    export "INSTALL_LANG_${tool_normalized}=$enabled"
  done
  
  for tool enabled in "${(@kv)EDITORS}"; do
    local tool_normalized="${tool:u}"
    tool_normalized="${tool_normalized//-/_}"
    export "INSTALL_EDITOR_${tool_normalized}=$enabled"
  done
  
  for tool enabled in "${(@kv)SHELLS}"; do
    local tool_normalized="${tool:u}"
    tool_normalized="${tool_normalized//-/_}"
    export "INSTALL_SHELL_${tool_normalized}=$enabled"
  done
  
  for tool enabled in "${(@kv)TERMINALS}"; do
    local tool_normalized="${tool:u}"
    tool_normalized="${tool_normalized//-/_}"
    export "INSTALL_TERMINAL_${tool_normalized}=$enabled"
  done
  
  for tool enabled in "${(@kv)TERMINAL_TOOLS}"; do
    local tool_normalized="${tool:u}"
    tool_normalized="${tool_normalized//-/_}"
    export "INSTALL_TERMINAL_TOOL_${tool_normalized}=$enabled"
  done
  
  for tool enabled in "${(@kv)DEVOPS_TOOLS}"; do
    local tool_normalized="${tool:u}"
    tool_normalized="${tool_normalized//-/_}"
    export "INSTALL_DEVOPS_${tool_normalized}=$enabled"
  done
  
  for tool enabled in "${(@kv)BUILD_TOOLS}"; do
    local tool_normalized="${tool:u}"
    tool_normalized="${tool_normalized//-/_}"
    export "INSTALL_BUILD_${tool_normalized}=$enabled"
  done
  
  for tool enabled in "${(@kv)SHELL_UTILS}"; do
    local tool_normalized="${tool:u}"
    tool_normalized="${tool_normalized//-/_}"
    export "INSTALL_SHELL_UTIL_${tool_normalized}=$enabled"
  done
  
  for tool enabled in "${(@kv)AI_TOOLS}"; do
    local tool_normalized="${tool:u}"
    tool_normalized="${tool_normalized//-/_}"
    export "INSTALL_AI_${tool_normalized}=$enabled"
  done
  
  for tool enabled in "${(@kv)GIT_TOOLS}"; do
    local tool_normalized="${tool:u}"
    tool_normalized="${tool_normalized//-/_}"
    export "INSTALL_GIT_${tool_normalized}=$enabled"
  done
  
  for tool enabled in "${(@kv)WM_TOOLS}"; do
    local tool_normalized="${tool:u}"
    tool_normalized="${tool_normalized//-/_}"
    export "INSTALL_WM_${tool_normalized}=$enabled"
  done
  
  # Signal that config is loaded
  export INSTALL_CONFIG_LOADED=1
}

# Auto-export if sourced
if [[ "${(%):-%x}" != "${0}" ]]; then
  export_config
fi
