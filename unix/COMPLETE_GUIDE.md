# Complete Installation Guide

## Quick Reference

### Primary Entry Point
```bash
./unix.sh [options] [categories...]
```

This single command at the repository root handles everything!

---

## The Three Modes

### 1️⃣ Config Mode (Recommended for Repeatability)

**Best for**: Reproducible setups, automation, sharing configs

```bash
# Step 1: Edit your preferences once
nano sh/config.sh

# Step 2: Run installer with config
./unix.sh --use-config

# Optional: Override config with flags
./unix.sh --use-config --exclude devops
./unix.sh --use-config --only cli
```

**How it works:**
- Reads `sh/config.sh` for all installation decisions
- No prompts during installation
- Can override with `--exclude` or `--only` flags
- Skips already-installed tools automatically

---

### 2️⃣ Interactive Mode (Default)

**Best for**: First-time setup, exploration

```bash
# Just run without arguments
./unix.sh

# It will:
# 1. List all available categories
# 2. Prompt you to select categories
# 3. Prompt Y/n for each tool within selected categories
```

**How it works:**
- Prompts for category selection
- Then prompts for each individual tool
- Good for learning what's available

---

### 3️⃣ CLI Arguments Mode

**Best for**: One-off installations, specific needs

```bash
# Install specific categories
./unix.sh cli langs editors

# Install everything
./unix.sh --all

# Install everything except certain categories
./unix.sh --all --exclude devops --exclude docker

# Preview what would be installed (dry run)
./unix.sh --dry-run cli langs
```

**How it works:**
- Specify categories as arguments
- Still prompts Y/n for each tool (unless `-y` flag used)
- Quick for targeted installations

---

## Common Use Cases

### New Machine Setup
```bash
# 1. Clone your config from another machine
scp oldmachine:~/devenv/install/sh/config.sh ./sh/

# 2. Run installation
./unix.sh --use-config

# Done! Same environment on new machine
```

### Development Environment
```bash
# Quick dev setup
./unix.sh cli langs editors git

# Or with config
./unix.sh --use-config --only cli --only langs
```

### CI/CD Setup
```bash
# Non-interactive, specific tools
./unix.sh --yes cli build

# Or with config
export INSTALL_NONINTERACTIVE=1
./unix.sh --use-config
```

### Preview Before Installing
```bash
# See what config would install
./unix.sh --dry-run --use-config

# See what specific categories would install
./unix.sh --dry-run cli langs editors
```

---

## All Available Options

```
OPTIONS:
  -h, --help           Show help message
  -l, --list          List all available categories
  -c, --use-config    Use config.sh for decisions
  -a, --all           Install all categories
  -e, --exclude       Exclude categories (repeatable)
  -o, --only          Only specified categories (config mode)
  -d, --dry-run       Preview without installing
  -i, --interactive   Force interactive mode
  -y, --yes           Skip all prompts
```

---

## Available Categories

| Category | Description |
|----------|-------------|
| `cli` | Modern CLI tools (ripgrep, fzf, bat, eza, jq, zoxide) |
| `langs` | Programming languages (rust, go, node, python, zig) |
| `editors` | Text editors (neovim, emacs, zed, helix) |
| `shells` | Shell environments (fish, zsh, oh-my-zsh, starship) |
| `terminals` | Terminal emulators (wezterm, kitty, ghostty, alacritty) |
| `terminal-tools` | Terminal programs (tmux, lazygit, yazi, gh-dash) |
| `devops` | DevOps tools (docker, kubernetes, colima, helm, k9s) |
| `build` | Build tools (cmake, make, ninja, meson) |
| `shell-utils` | Shell utilities (direnv, doppler, fastfetch, starship) |
| `ai` | AI tools (copilot-cli, claude, ollama) |
| `git` | Git tools (gh, glab) |
| `wm` | Window managers (aerospace, hyprland, yabai) |

---

## Configuration File Format

Edit `sh/config.sh`:

```bash
# Enable/disable entire categories
INSTALL_CATEGORY_CLI=1      # Install CLI tools
INSTALL_CATEGORY_DEVOPS=0   # Skip DevOps tools

# Enable/disable individual tools
INSTALL_CLI_RIPGREP=1       # Install ripgrep
INSTALL_CLI_BAT=0           # Skip bat
INSTALL_LANG_RUST=1         # Install Rust
INSTALL_EDITOR_NEOVIM=1     # Install Neovim
```

**Naming convention:**
- Categories: `INSTALL_CATEGORY_<NAME>`
- Tools: `INSTALL_<CATEGORY>_<TOOL>`
- Use UPPERCASE and underscores

---

## Alternative Entry Points

### From sh/ Directory
```bash
cd sh/
./install.sh --use-config    # Same as ./unix.sh --use-config
./install.sh cli langs       # Same as ./unix.sh cli langs
```

### Old Scripts (Deprecated but Working)
```bash
# This still works but shows deprecation warning
./sh/install-with-config.sh

# Redirects to: ./sh/install.sh --use-config
```

---

## Troubleshooting

### Check What Would Install
```bash
# Preview config mode
./unix.sh --dry-run --use-config

# Preview specific categories
./unix.sh --dry-run cli langs
```

### List Available Categories
```bash
./unix.sh --list
```

### Get Help
```bash
./unix.sh --help
```

### Verify Config Syntax
```bash
# Check bash syntax
bash -n sh/config.sh

# Test config loading
source sh/config.sh && echo "Config loaded: $INSTALL_CONFIG_LOADED"
```

---

## Tips & Best Practices

1. **Use Config Mode for Consistency**
   - Edit `config.sh` once
   - Version control it
   - Share across machines

2. **Dry Run First**
   - Always preview with `--dry-run` before installing
   - Especially when using `--all`

3. **Exclude What You Don't Need**
   - DevOps tools are heavy (Docker, K8s)
   - Use `--exclude devops` if not needed

4. **Re-running is Safe**
   - Already-installed tools are skipped
   - Safe to re-run with updated config

5. **Start Small**
   - Begin with: `./unix.sh cli langs`
   - Add more categories as needed

---

## Examples by Scenario

### Minimal Developer Setup
```bash
./unix.sh cli langs editors git
```

### Full Stack Developer
```bash
./unix.sh --use-config
# (with all categories enabled in config.sh)
```

### System Administrator
```bash
./unix.sh cli terminal-tools devops
```

### Data Scientist
```bash
./unix.sh cli langs
# Just CLI tools and Python
```

### Just Try Things Out
```bash
# Interactive - explore and decide
./unix.sh
```

---

## Summary

✅ **One entry point**: `./unix.sh`  
✅ **Three modes**: Config, Interactive, CLI Arguments  
✅ **POSIX compliant**: Works on any Unix-like system  
✅ **Flexible**: Mix modes and override as needed  

**Start here:**
```bash
./unix.sh --help
```

That's it! 🚀
