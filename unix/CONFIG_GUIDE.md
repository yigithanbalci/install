# Installation System - Complete Guide

## **How It Works**

### **Current System Overview**

The installation system has evolved into two approaches:

1. **Old System** (`./install`): Legacy script that finds executables in `installs/`
2. **New System** (`./sh/install.sh`): Modern, organized category-based scripts

### **Script Structure**

Each installation script (e.g., `cli.sh`, `editors.sh`, `git.sh`) follows this pattern:

```bash
#!/usr/bin/env bash
source "$SCRIPT_DIR/common.sh"  # Load shared utilities

# One function per tool
install_ripgrep() {
  if is_installed ripgrep; then return 0; fi  # Skip if already installed
  
  case "$OS" in
    macos) pkg_install ripgrep ;;
    ubuntu) pkg_install ripgrep ;;
    arch) pkg_install ripgrep ;;
  esac
}

# Main function calls all install functions
main() {
  local tools=("ripgrep" "fzf" "bat")
  
  for tool in "${tools[@]}"; do
    if confirm_install "$tool" "cli"; then  # Check config or prompt user
      install_$tool || log_error "Failed to install $tool"
    fi
  done
}

main
```

### **Key Components**

- **`common.sh`**: Shared utilities (logging, OS detection, package installation)
- **`confirm_install()`**: Checks config file OR prompts user interactively
- **Each category script**: Contains `install_<tool>()` functions
- **`main()` function**: Orchestrates which tools to install

---

## **Three Ways to Install**

### **1. Interactive Mode (Original)**

Prompts you for each tool:

```bash
./sh/install.sh cli              # Install CLI tools (prompts for each)
./sh/install.sh --all            # Install everything (prompts for each)
```

**How it works:**
- Script calls `confirm_install()` for each tool
- You answer "Y/n" for each one
- **Problem**: Tedious for many tools, can't save preferences

### **2. Non-Interactive Mode**

Installs everything without prompts:

```bash
INSTALL_NONINTERACTIVE=1 ./sh/install.sh --all   # Install EVERYTHING
INSTALL_NONINTERACTIVE=1 ./sh/install.sh cli     # Install all CLI tools
```

**How it works:**
- Sets environment variable to skip all prompts
- **Problem**: All-or-nothing, can't exclude specific tools

### **3. Config-Based Mode (NEW ✨)**

Define what you want in a config file, no prompts needed:

```bash
# 1. Edit config.zsh to enable/disable tools
nano sh/config.zsh

# 2. Run installer
./sh/install-with-config.sh              # Install based on config
./sh/install-with-config.sh --dry-run    # Preview what would install
```

**How it works:**
- Config file defines enabled/disabled tools
- `confirm_install()` reads config automatically
- No prompts, installs only what's enabled
- **Benefit**: Save preferences, reproducible, fast

---

## **Using the Config System**

### **Step 1: Edit `config.zsh`**

Open `sh/config.zsh` and set tools to `1` (enabled) or `0` (disabled):

```zsh
# Categories - enable/disable entire categories
typeset -A INSTALL_CATEGORIES
INSTALL_CATEGORIES=(
  [cli]=1              # Enable CLI tools
  [langs]=1            # Enable languages
  [editors]=1          # Enable editors
  [devops]=0           # DISABLE DevOps tools
  [git]=1              # Enable git tools
  [wm]=1               # Enable window managers
)

# Individual tools within CLI category
typeset -A CLI_TOOLS
CLI_TOOLS=(
  [ripgrep]=1          # Enable ripgrep
  [fzf]=1              # Enable fzf
  [bat]=1              # Enable bat
  [lazygit]=1          # Enable lazygit
  [television]=0       # DISABLE television
)

# Git tools
typeset -A GIT_TOOLS
GIT_TOOLS=(
  [gh]=1               # Enable GitHub CLI
  [glab]=1             # Enable GitLab CLI
)

# Window managers
typeset -A WM_TOOLS
WM_TOOLS=(
  [aerospace]=1        # Enable AeroSpace (macOS)
  [yabai]=0            # Disable yabai
  [hyprland]=1         # Enable Hyprland (Arch)
)
```

### **Step 2: Run the Installer**

```bash
# Preview what will be installed
./sh/install-with-config.sh --dry-run

# Install everything enabled in config
./sh/install-with-config.sh
```

### **Step 3: Update Config Over Time**

Just edit `config.zsh` and run again. Already-installed tools are skipped automatically.

---

## **Config System Behavior**

### **Priority Order**

1. **Category disabled** → Skip entire category
2. **Tool explicitly disabled** → Skip that tool
3. **Tool enabled or not listed** → Install it

### **Example Scenarios**

**Scenario 1**: Category disabled
```zsh
INSTALL_CATEGORIES=([cli]=0)  # Entire CLI category disabled
CLI_TOOLS=([ripgrep]=1)       # ripgrep won't install (category overrides)
```

**Scenario 2**: Category enabled, tool disabled
```zsh
INSTALL_CATEGORIES=([cli]=1)  # CLI category enabled
CLI_TOOLS=([ripgrep]=0)       # ripgrep specifically disabled
# Result: All CLI tools install EXCEPT ripgrep
```

**Scenario 3**: Tool not listed in config
```zsh
CLI_TOOLS=([ripgrep]=1 [fzf]=1)  # Only lists 2 tools
# Result: ripgrep and fzf install, others use default (install)
```

---

## **Available Categories**

| Category | Script | Description |
|----------|--------|-------------|
| `cli` | `cli.sh` | Modern CLI tools (ripgrep, fzf, bat, eza, etc.) |
| `langs` | `langs.sh` | Languages (rust, go, node, python) |
| `editors` | `editors.sh` | Text editors (neovim, emacs, zed) |
| `shells` | `shells.sh` | Shells (fish, zsh, bash) |
| `terminals` | `terminals.sh` | Terminal emulators (wezterm, kitty) |
| `terminal-tools` | `terminal-tools.sh` | Terminal programs (tmux, yazi) |
| `devops` | `devops.sh` | DevOps (docker, kubernetes, colima) |
| `build` | `build.sh` | Build tools (cmake, make) |
| `shell-utils` | `shell-utils.sh` | Shell utilities (direnv, starship) |
| `ai` | `ai.sh` | AI tools (copilot-cli, claude) |
| `git` | `git.sh` | Git tools (gh, glab) |
| `wm` | `wm.sh` | Window managers (aerospace, hyprland) |

---

## **Complete Examples**

### **Example 1: Minimal Development Setup**

```zsh
# config.zsh
INSTALL_CATEGORIES=(
  [cli]=1
  [langs]=1
  [editors]=1
  [git]=1
  [shells]=0
  [devops]=0
  [wm]=0
)

CLI_TOOLS=(
  [ripgrep]=1
  [fzf]=1
  [bat]=1
  [eza]=1
  [zoxide]=1
  [lazygit]=1
)

LANGS=(
  [rust]=1
  [node]=1
  [python]=1
  [go]=0
)

EDITORS=([neovim]=1 [zed]=0 [emacs]=0)
GIT_TOOLS=([gh]=1 [glab]=0)
```

Run: `./sh/install-with-config.sh`

### **Example 2: Full Setup (Everything)**

```zsh
# Set all categories to 1
INSTALL_CATEGORIES=(
  [cli]=1
  [langs]=1
  [editors]=1
  [shells]=1
  [terminals]=1
  [terminal-tools]=1
  [devops]=1
  [build]=1
  [shell-utils]=1
  [ai]=1
  [git]=1
  [wm]=1
)

# All tools enabled (default)
# No need to list individual tools
```

Run: `./sh/install-with-config.sh`

### **Example 3: Work Machine (No Personal Tools)**

```zsh
INSTALL_CATEGORIES=(
  [cli]=1
  [langs]=1
  [editors]=1
  [git]=1
  [devops]=1
  [wm]=0           # No window managers
  [ai]=0           # No AI tools
  [terminals]=0    # Use default terminal
)

WM_TOOLS=([aerospace]=0 [yabai]=0)
AI_TOOLS=([copilot-cli]=0)
```

---

## **Migrating from Old System**

If you were using `./install` or interactive prompts:

1. **Copy your typical selections** to `config.zsh`
2. **Test with dry-run**: `./sh/install-with-config.sh --dry-run`
3. **Run installation**: `./sh/install-with-config.sh`
4. **Update config.zsh** as needed and re-run

---

## **Troubleshooting**

### **Config not loading**

```bash
# Check if zsh is installed
which zsh

# Manually test config
zsh -c "source ./sh/config.zsh && export_config && env | grep INSTALL_"
```

### **Tool still prompts despite config**

Make sure the script's `confirm_install()` call includes category name:

```bash
# ✅ Correct (reads config)
confirm_install "ripgrep" "cli"

# ❌ Wrong (always prompts)
confirm_install "ripgrep"
```

### **Want to add a new tool**

1. Add to appropriate section in `config.zsh`
2. Update the corresponding script (e.g., `cli.sh`)
3. Add `install_<tool>()` function
4. Add tool to `main()` function's array

---

## **Quick Reference**

```bash
# Interactive (original)
./sh/install.sh cli                      # Prompts for each CLI tool

# Non-interactive (all or nothing)
INSTALL_NONINTERACTIVE=1 ./sh/install.sh --all

# Config-based (recommended)
./sh/install-with-config.sh              # Uses config.zsh
./sh/install-with-config.sh --dry-run    # Preview

# Individual category scripts (if needed)
./sh/cli.sh                              # Install CLI tools
./sh/git.sh                              # Install git tools
./sh/wm.sh                               # Install window managers
```

---

## **Benefits of Config System**

✅ **Reproducible**: Same config = same tools across machines  
✅ **Fast**: No prompts, runs automatically  
✅ **Versioned**: Config file can be committed to git  
✅ **Flexible**: Enable/disable at category or tool level  
✅ **Safe**: Dry-run mode to preview changes  
✅ **Idempotent**: Re-running is safe, skips installed tools  

---

## **Next Steps**

1. **Edit `config.zsh`** to match your preferences
2. **Test with dry-run** to verify settings
3. **Run installer** and enjoy automated setup
4. **Commit config.zsh** to version control
5. **Share across machines** for consistent environments
