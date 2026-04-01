# Technical Structure Documentation

This document describes the technical architecture, implementation details, and internals of the Unix installation system.

## Table of Contents

- [System Architecture](#system-architecture)
- [File Organization](#file-organization)
- [Installation Flow](#installation-flow)
- [Configuration System](#configuration-system)
- [Tool Checking Mechanism](#tool-checking-mechanism)
- [Adding New Tools](#adding-new-tools)
- [Adding New Categories](#adding-new-categories)
- [POSIX Compliance](#posix-compliance)

## System Architecture

```
┌─────────────┐
│  unix.sh    │  Entry point (repository root)
│ (delegate)  │
└──────┬──────┘
       │
       │ exec unix/install.sh "$@"
       │
       ▼
┌──────────────────────────────────────┐
│     unix/install.sh                  │  Main installer (mode detection, parsing)
│  ┌────────────────────────────────┐  │
│  │ Mode: Config / Interactive / CLI │  │
│  └────────────────────────────────┘  │
└────────┬─────────────────────────────┘
         │
         │ Sources
         ▼
    ┌────────────┐
    │ config.sh  │  (if --use-config)
    └────────────┘
         │
         │ For each category
         ▼
┌─────────────────────────────────┐
│  Category Scripts               │
│  cli.sh, langs.sh, editors.sh   │
│  shells.sh, terminals.sh, etc.  │
│                                 │
│  Each sources common.sh         │
└────────┬────────────────────────┘
         │
         │ Sources
         ▼
    ┌────────────┐
    │ common.sh  │  Shared utilities
    └────────────┘
```

## File Organization

### Core Files

| File | Purpose | Key Functions |
|------|---------|---------------|
| **unix.sh** | Root entry point | Simple wrapper: `exec unix/install.sh "$@"` |
| **install.sh** | Main installer | `parse_args()`, `load_config()`, `get_categories_to_install()`, mode detection |
| **config.sh** | Configuration | `is_category_enabled()`, `is_tool_enabled()`, `export_config()` |
| **common.sh** | Shared utilities | `confirm_install()`, `pkg_install()`, `command_exists()`, `detect_os()` |

### Category Scripts

Each category script follows the same pattern:
- **ai.sh** - AI tools (copilot-cli, claude-cli, aichat, ollama)
- **build.sh** - Build systems (cmake, make, ninja, meson)
- **cli.sh** - Modern CLI tools (ripgrep, fzf, fd, bat, eza, jq, etc.)
- **devops.sh** - DevOps tools (docker, kubectl, helm, k9s)
- **editors.sh** - Text editors (neovim, emacs, zed, helix)
- **git.sh** - Git tools (gh, glab)
- **langs.sh** - Programming languages (rust, go, node, python, etc.)
- **shell-utils.sh** - Shell utilities (direnv, doppler, fastfetch, pass)
- **shells.sh** - Shells (fish, zsh, oh-my-zsh, starship)
- **terminal-tools.sh** - Terminal programs (tmux, lazygit, yazi, etc.)
- **terminals.sh** - Terminal emulators (wezterm, kitty, ghostty, alacritty)
- **wm.sh** - Window managers (aerospace, yabai, hyprland)

### Legacy/Deprecated

- **install-with-config.sh** - Deprecated wrapper, shows warning and redirects to `install.sh --use-config`
- **config.zsh** - Old ZSH config (kept for reference, replaced by config.sh)

## Installation Flow

### 1. Entry Point (`unix.sh`)

```bash
#!/usr/bin/env bash
exec "$(dirname "${BASH_SOURCE[0]}")/unix/install.sh" "$@"
```

Simple delegation to the main installer in unix/ directory.

### 2. Main Installer (`install.sh`)

**Key stages:**

1. **Argument parsing** (`parse_args()`)
   - Detects `--use-config` flag → sets `USE_CONFIG=1`
   - Detects category names → populates `ONLY_CATEGORIES` array
   - Detects flags: `--all`, `--exclude`, `--only`, `--dry-run`, `--yes`

2. **Mode determination**
   ```bash
   if [ "$USE_CONFIG" = "1" ]; then
       MODE="config"
   elif [ ${#ONLY_CATEGORIES[@]} -gt 0 ]; then
       MODE="cli"
   else
       MODE="interactive"
       INTERACTIVE=1
   fi
   ```

3. **Config loading** (if `--use-config`)
   ```bash
   source "$(dirname "$0")/config.sh"
   export_config  # Exports all INSTALL_* variables
   INSTALL_CONFIG_LOADED=1
   ```

4. **Config overrides** (if `--exclude` or `--only` with config)
   - `--exclude`: Sets `INSTALL_CATEGORY_<NAME>=0` for excluded categories
   - `--only`: Sets all categories to 0, then enables only specified ones

5. **Category selection** (`get_categories_to_install()`)
   - **Config mode**: Checks `is_category_enabled()` for each category
   - **Interactive mode**: Prompts user to select categories
   - **CLI mode**: Uses categories from `ONLY_CATEGORIES` array

6. **Category execution**
   ```bash
   for category in "${categories[@]}"; do
       bash "$(dirname "$0")/${category}.sh"
   done
   ```

### 3. Category Script Execution (e.g., `cli.sh`)

**Standard pattern:**

```bash
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

install_ripgrep() {
    # Installation logic
}

install_fzf() {
    # Installation logic
}

main() {
    local tools=("ripgrep" "fzf" "fd" "bat" "eza" "jq" ...)
    
    for tool in "${tools[@]}"; do
        if confirm_install "$tool" "cli"; then
            "install_${tool//-/_}"  # Call install_ripgrep, install_fzf, etc.
        fi
    done
}

main "$@"
```

**Key points:**
- Sources `common.sh` for utilities
- Defines `install_<tool>()` functions for each tool
- `main()` iterates through tools array
- Calls `confirm_install(tool, category)` before each installation
- Tool name normalization: `install_copilot-cli` → `install_copilot_cli`

## Configuration System

### Variable Naming Convention

**Categories:**
```bash
INSTALL_CATEGORY_CLI=1           # Enable CLI tools category
INSTALL_CATEGORY_DEVOPS=0        # Disable DevOps category
```

**Tools:**
```bash
INSTALL_CLI_RIPGREP=1            # Enable ripgrep in CLI category
INSTALL_CLI_BAT=0                # Disable bat in CLI category
INSTALL_LANG_RUST=1              # Enable Rust in langs category
```

**Naming rules:**
- All uppercase
- Prefix: `INSTALL_CATEGORY_` or `INSTALL_<CATEGORY>_`
- Hyphens in tool/category names → underscores
- Examples:
  - `copilot-cli` → `INSTALL_AI_COPILOT_CLI`
  - `shell-utils` → `INSTALL_CATEGORY_SHELL_UTILS`
  - `tree-sitter` → `INSTALL_CLI_TREE_SITTER`

### Configuration Functions (`config.sh`)

**`is_category_enabled(category)`**
```bash
is_category_enabled() {
    local category="$1"
    local var_name="INSTALL_CATEGORY_${category^^}"
    var_name="${var_name//-/_}"
    local value="${!var_name}"
    [ "$value" = "1" ]
}
```
- Converts category name to uppercase
- Replaces hyphens with underscores
- Returns 0 (true) if value is "1", 1 (false) otherwise

**`is_tool_enabled(category, tool)`**
```bash
is_tool_enabled() {
    local category="$1"
    local tool="$2"
    local var_name="INSTALL_${category^^}_${tool^^}"
    var_name="${var_name//-/_}"
    local value="${!var_name}"
    [ "$value" = "1" ]
}
```
- Same pattern as `is_category_enabled`
- Checks tool-specific variable

**`export_config()`**
```bash
export_config() {
    export INSTALL_CATEGORY_CLI INSTALL_CATEGORY_LANGS ...
    export INSTALL_CLI_RIPGREP INSTALL_CLI_FZF ...
    export INSTALL_LANG_RUST INSTALL_LANG_GO ...
    # ... exports all variables
}
```
- Exports all configuration variables to environment
- Called by `install.sh` when loading config

### Auto-Export on Source

```bash
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    export_config
fi
```

When `config.sh` is sourced (not executed), automatically exports all variables.

## Tool Checking Mechanism

The `confirm_install()` function in `common.sh` is the central decision point for whether to install a tool.

### Function Signature

```bash
confirm_install(tool_name, category)
```

### Decision Logic

```bash
confirm_install() {
    local tool="$1"
    local category="$2"
    
    # 1. Check if already installed
    if is_installed "$tool"; then
        return 1  # Skip
    fi
    
    # 2. Config mode: check category + tool enabled
    if [ "$INSTALL_CONFIG_LOADED" = "1" ]; then
        if ! is_category_enabled "$category"; then
            return 1  # Category disabled
        fi
        if ! is_tool_enabled "$category" "$tool"; then
            return 1  # Tool disabled
        fi
        return 0  # Install
    fi
    
    # 3. Non-interactive mode (--yes flag)
    if [ "$INSTALL_NONINTERACTIVE" = "1" ]; then
        return 0  # Install without prompting
    fi
    
    # 4. Interactive: prompt user
    local response
    read -p "Install $tool? (Y/n): " response
    case "${response,,}" in
        n|no) return 1 ;;
        *) return 0 ;;
    esac
}
```

### Return Values

- **0** (true) - Proceed with installation
- **1** (false) - Skip installation

### Usage in Category Scripts

```bash
for tool in "${tools[@]}"; do
    if confirm_install "$tool" "cli"; then
        install_function="${tool//-/_}"  # ripgrep → ripgrep, copilot-cli → copilot_cli
        "install_${install_function}"
    fi
done
```

## Adding New Tools

### 1. Choose the Right Category

Identify which category script the tool belongs to (cli, langs, editors, etc.).

### 2. Add Install Function

In the category script (e.g., `cli.sh`), add an installation function:

```bash
install_mytool() {
    info "Installing mytool..."
    
    case "$OS" in
        macos)
            pkg_install "mytool"  # Homebrew
            ;;
        ubuntu|debian)
            pkg_install "mytool"  # apt
            ;;
        arch)
            pkg_install "mytool"  # pacman
            ;;
        *)
            # Fallback: curl install
            curl -sSL https://example.com/install.sh | bash
            ;;
    esac
    
    if command_exists mytool; then
        success "mytool installed successfully"
    else
        error "Failed to install mytool"
    fi
}
```

### 3. Add to Tools Array

In the `main()` function of the category script:

```bash
main() {
    local tools=(
        "ripgrep"
        "fzf"
        "mytool"    # Add here
        "bat"
        "eza"
    )
    
    for tool in "${tools[@]}"; do
        if confirm_install "$tool" "cli"; then
            "install_${tool//-/_}"
        fi
    done
}
```

### 4. Add to Configuration

In `config.sh`, add configuration variable:

```bash
# CLI Tools Configuration
INSTALL_CLI_RIPGREP=1
INSTALL_CLI_FZF=1
INSTALL_CLI_MYTOOL=1      # Add here
INSTALL_CLI_BAT=1
```

And add to `export_config()`:

```bash
export_config() {
    # ... existing exports ...
    export INSTALL_CLI_MYTOOL
}
```

### 5. Update Documentation

Add the tool to the category table in `README.md`:

```markdown
| **cli** | Modern CLI tools: ripgrep, fzf, mytool, bat, eza, ... |
```

## Adding New Categories

### 1. Create Category Script

Create `unix/mynewcategory.sh`:

```bash
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

install_tool1() {
    info "Installing tool1..."
    # Installation logic
}

install_tool2() {
    info "Installing tool2..."
    # Installation logic
}

main() {
    local tools=("tool1" "tool2")
    
    for tool in "${tools[@]}"; do
        if confirm_install "$tool" "mynewcategory"; then
            "install_${tool//-/_}"
        fi
    done
}

main "$@"
```

### 2. Add to Configuration

In `config.sh`:

```bash
# New Category Configuration
INSTALL_CATEGORY_MYNEWCATEGORY=1

# Tool-specific settings
INSTALL_MYNEWCATEGORY_TOOL1=1
INSTALL_MYNEWCATEGORY_TOOL2=1
```

Add to `export_config()`:

```bash
export_config() {
    # Categories
    export INSTALL_CATEGORY_MYNEWCATEGORY
    
    # Tools
    export INSTALL_MYNEWCATEGORY_TOOL1
    export INSTALL_MYNEWCATEGORY_TOOL2
}
```

Add helper integration:

```bash
is_category_enabled() {
    # ... existing code ...
}

is_tool_enabled() {
    # ... existing code ...
}
```

### 3. Add to Main Installer

In `install.sh`, add to available categories list:

```bash
# Around line 50
ALL_CATEGORIES=(
    "cli"
    "langs"
    "mynewcategory"    # Add here
    "editors"
    "shells"
    # ...
)
```

### 4. Update Documentation

Add to `README.md`:

```markdown
| **mynewcategory** | Description: tool1, tool2, ... |
```

## POSIX Compliance

All scripts are POSIX-compliant bash and avoid zsh-specific features.

### Key Differences from ZSH

**Associative Arrays → Simple Variables**

❌ **ZSH (not POSIX):**
```bash
typeset -A INSTALL_CATEGORIES
INSTALL_CATEGORIES=([cli]=1 [langs]=1)
```

✅ **POSIX Bash:**
```bash
INSTALL_CATEGORY_CLI=1
INSTALL_CATEGORY_LANGS=1
```

**Source Detection**

```bash
# Check if sourced vs executed
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    # Sourced - auto-export
    export_config
fi
```

### Compatibility Requirements

- **Shebang**: `#!/usr/bin/env bash` (portable, finds bash in PATH)
- **No ZSH features**: No associative arrays, no ZSH-specific builtins
- **Standard utilities**: Only POSIX tools (no GNU-specific flags when possible)
- **Quoting**: Always quote variables: `"$var"`, `"${array[@]}"`
- **Portability**: Works on macOS (BSD), Ubuntu (GNU), Arch, minimal Linux

### Syntax Checking

Verify POSIX compliance:

```bash
# Check syntax
bash -n unix/install.sh

# Shellcheck (if installed)
shellcheck unix/*.sh
```

## Utility Functions Reference

### `common.sh` Functions

**`detect_os()`**
- Returns: `macos`, `ubuntu`, `arch`, or `linux-unknown`
- Used to branch installation logic by OS

**`command_exists(command)`**
- Returns: 0 if command exists, 1 otherwise
- Uses `command -v` (POSIX)

**`is_installed(tool)`**
- Checks if tool already installed, logs if found
- Returns: 0 if installed, 1 if not

**`pkg_install(package)`**
- OS-agnostic package installation
- Uses Homebrew (macOS), apt (Ubuntu), pacman (Arch)

**`confirm_install(tool, category)`**
- Main decision function for tool installation
- Respects config, non-interactive mode, prompts if interactive

**Logging Functions:**
- `info(message)` - Blue informational message
- `success(message)` - Green success message
- `error(message)` - Red error message
- `warning(message)` - Yellow warning message

### Environment Variables

**Set by installer:**
- `INSTALL_CONFIG_LOADED=1` - Config mode active
- `INSTALL_NONINTERACTIVE=1` - Skip all prompts (--yes flag)
- `INTERACTIVE=1` - Interactive mode active
- `DRY_RUN=1` - Preview mode (--dry-run)

**Set by config:**
- `INSTALL_CATEGORY_<NAME>=1/0` - Category enabled/disabled
- `INSTALL_<CATEGORY>_<TOOL>=1/0` - Tool enabled/disabled

**OS Detection:**
- `OS` - Detected OS (macos/ubuntu/arch/linux-unknown)

## Debugging Tips

### Enable Verbose Mode

```bash
bash -x ./unix.sh --use-config
```

### Check Config Loading

```bash
source unix/config.sh
echo "Config loaded: $INSTALL_CONFIG_LOADED"
is_category_enabled "cli" && echo "CLI enabled"
```

### Test Single Category

```bash
bash unix/cli.sh  # Run CLI category directly
```

### Dry-Run Mode

```bash
./unix.sh --dry-run --use-config
```

### Check Tool Detection

```bash
source unix/common.sh
detect_os
echo "OS: $OS"
command_exists ripgrep && echo "ripgrep found"
```

## Script Lifecycle

1. **unix.sh** (root) executes
2. **install.sh** sources, parses arguments, determines mode
3. **config.sh** sourced (if `--use-config`), variables exported
4. Category selection based on mode
5. For each category, **execute category script** (e.g., `cli.sh`)
6. Category script sources **common.sh**
7. Category script's `main()` iterates tools
8. For each tool, call **confirm_install(tool, category)**
9. If confirmed, call **install_<tool>()** function
10. Installation uses **pkg_install()** or custom logic
11. Verify with **command_exists()** or **is_installed()**

---

**Maintainers:** When modifying the system, ensure POSIX compliance, update both README.md and this file, and test on macOS, Ubuntu, and Arch Linux.
