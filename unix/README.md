# Unix Installation System

A unified, POSIX-compliant installation system for development tools on Unix-based operating systems (macOS, Ubuntu, Arch Linux, etc.).

## Quick Start

```bash
# From repository root
./unix.sh                    # Interactive mode
./unix.sh --use-config       # Config-based (uses unix/config.sh)
./unix.sh cli langs          # Install specific categories
./unix.sh --help             # Show all options
```

## Three Installation Modes

### 1. Config Mode (Recommended for Automation)
Uses `unix/config.sh` to decide what to install. No prompts during installation.

```bash
# Edit configuration
nano unix/config.sh

# Run installer
./unix.sh --use-config

# With overrides
./unix.sh --use-config --exclude devops
./unix.sh --use-config --only cli
```

**Benefits:** Reproducible, version-controlled, shareable across machines.

### 2. Interactive Mode (Default)
Prompts you to select categories and tools interactively.

```bash
# Run without arguments
./unix.sh

# Will prompt for:
# 1. Which categories to install
# 2. Which tools within each category
```

**Benefits:** Good for exploration and first-time setup.

### 3. CLI Arguments Mode
Install specific categories directly from command line.

```bash
# Install specific categories
./unix.sh cli langs editors

# Install everything
./unix.sh --all

# Exclude specific categories
./unix.sh --all --exclude devops --exclude docker

# Preview (dry-run)
./unix.sh --dry-run cli langs
```

**Benefits:** Quick, scriptable, no config file needed.

## Available Categories

| Category | Tools Included |
|----------|---------------|
| **cli** | Modern CLI tools: ripgrep, fzf, fd, bat, eza, jq, zoxide, atuin, tldr, stow, tree-sitter, lazygit, television, sesh |
| **langs** | Programming languages: Rust, Go, Node.js (via nvm), Zig, Python, GCC, G++, LLVM |
| **editors** | Text editors: Neovim, Emacs, Zed, Helix |
| **shells** | Shell environments: Fish, Zsh, Oh My Zsh, Starship |
| **terminals** | Terminal emulators: WezTerm, Kitty, Ghostty, Alacritty |
| **terminal-tools** | Terminal programs: tmux, lazygit, lazydocker, yazi, gh-dash, gtop, carapace |
| **devops** | DevOps tools: Docker, Docker Compose, Colima, kubectl, Helm, k9s |
| **build** | Build tools: CMake, Make, Ninja, Meson |
| **shell-utils** | Shell utilities: direnv, doppler, fastfetch, pass, neofetch, thefuck |
| **ai** | AI tools: GitHub Copilot CLI, Claude CLI, aichat, Ollama |
| **git** | Git tools: GitHub CLI (gh), GitLab CLI (glab) |
| **wm** | Window managers: AeroSpace (macOS), Yabai (macOS), Hyprland (Linux) |

## All Options

```
-h, --help           Show help message
-l, --list          List all available categories
-c, --use-config    Use config.sh for all installation decisions
-a, --all           Install all categories
-e, --exclude       Exclude categories (repeatable)
-o, --only          Only install specified categories (config mode)
-d, --dry-run       Preview without installing
-i, --interactive   Force interactive mode
-y, --yes           Skip all prompts (non-interactive)
```

## Configuration File

Edit `unix/config.sh` to customize your installation:

```bash
# Enable/disable entire categories
INSTALL_CATEGORY_CLI=1           # 1 = install, 0 = skip
INSTALL_CATEGORY_DEVOPS=0        # Skip DevOps tools

# Enable/disable individual tools
INSTALL_CLI_RIPGREP=1            # Install ripgrep
INSTALL_CLI_BAT=0                # Skip bat
INSTALL_LANG_RUST=1              # Install Rust
INSTALL_EDITOR_NEOVIM=1          # Install Neovim
```

**Naming convention:**
- Categories: `INSTALL_CATEGORY_<NAME>` (uppercase, underscores for hyphens)
- Tools: `INSTALL_<CATEGORY>_<TOOL>` (uppercase, underscores for hyphens)

## Common Use Cases

### New Machine Setup
```bash
# 1. Copy config from another machine
scp oldmachine:~/devenv/install/unix/config.sh ./unix/

# 2. Install everything
./unix.sh --use-config
```

### Development Environment
```bash
# Quick dev setup
./unix.sh cli langs editors git

# Or with config for repeatability
./unix.sh --use-config
```

### CI/CD / Automation
```bash
# Non-interactive mode
export INSTALL_NONINTERACTIVE=1
./unix.sh --use-config

# Or use -y flag
./unix.sh --yes cli build
```

### Preview Before Installing
```bash
# See what config would install
./unix.sh --dry-run --use-config

# See what categories would install
./unix.sh --dry-run cli langs
```

## How It Works

See [STRUCTURE.md](STRUCTURE.md) for detailed technical documentation on:
- System architecture
- Script organization
- Installation flow
- Configuration system
- Adding new tools

## Platform Support

- **macOS** (10.15+) - Uses Homebrew, official installers
- **Ubuntu/Debian** (20.04+) - Uses apt, official installers
- **Arch Linux** - Uses pacman, official installers
- **Other Linux** - Falls back to platform-agnostic curl installers

All scripts are POSIX-compliant bash and work on bare minimum terminal installations.

## Examples

### Example 1: Minimal Developer Setup
```bash
./unix.sh cli langs editors git
```

### Example 2: Full Stack Developer
```bash
# Edit config.sh to enable all categories
nano unix/config.sh

# Install based on config
./unix.sh --use-config
```

### Example 3: System Administrator
```bash
./unix.sh cli terminal-tools devops
```

### Example 4: Config with Overrides
```bash
# Use config but exclude heavy tools
./unix.sh --use-config --exclude devops

# Use config but only install CLI tools
./unix.sh --use-config --only cli
```

## Safety Features

- **Dry-run mode**: Preview installations with `--dry-run`
- **Skip installed**: Already-installed tools are automatically skipped
- **Confirmation prompts**: Asks before installing (unless `-y` or config mode)
- **Category filtering**: Install only what you need
- **Override support**: CLI flags override config settings

## Troubleshooting

### List Available Categories
```bash
./unix.sh --list
```

### Check Configuration
```bash
# Verify config syntax
bash -n unix/config.sh

# Test config loading
source unix/config.sh && echo "Config: $INSTALL_CONFIG_LOADED"
```

### Preview Installation
```bash
# Always safe to dry-run first
./unix.sh --dry-run --use-config
```

### Get Help
```bash
./unix.sh --help
```

## Entry Points

- **`./unix.sh`** (repository root) - Main entry point, delegates to unix/install.sh
- **`unix/install.sh`** - Actual installer, can be called directly from unix/ directory

Both accept the same arguments and options.

## See Also

- [STRUCTURE.md](STRUCTURE.md) - Technical documentation and architecture
- [config.sh](config.sh) - Configuration file (edit this to customize)
- [common.sh](common.sh) - Shared utilities used by all scripts

---

**Status:** Production-ready, POSIX-compliant, tested on macOS, Ubuntu, and Arch Linux.
