# Installation System - Cheatsheet

## **Quick Commands**

```bash
# Config-based (recommended)
./sh/install-with-config.sh              # Install using config
./sh/install-with-config.sh --dry-run    # Preview what will install

# Edit config
nano sh/config.zsh                       # Edit preferences

# Interactive (original)
./sh/install.sh                          # Interactive menu
./sh/install.sh cli                      # Install CLI tools
./sh/install.sh --all                    # Install everything

# Non-interactive (all-or-nothing)
INSTALL_NONINTERACTIVE=1 ./sh/install.sh --all

# Individual categories
./sh/cli.sh                              # CLI tools only
./sh/git.sh                              # Git tools only
./sh/wm.sh                               # Window managers only
```

---

## **Config.zsh Syntax**

```zsh
# Categories (enable/disable whole groups)
INSTALL_CATEGORIES=(
  [cli]=1              # 1 = enabled, 0 = disabled
  [git]=1
  [wm]=0               # disabled
)

# Individual tools
CLI_TOOLS=(
  [ripgrep]=1          # Install ripgrep
  [bat]=0              # Skip bat
)

GIT_TOOLS=(
  [gh]=1               # GitHub CLI
  [glab]=1             # GitLab CLI
)

WM_TOOLS=(
  [aerospace]=1        # macOS tiling WM
  [hyprland]=1         # Linux WM
)
```

---

## **Available Categories**

| Category | Tools |
|----------|-------|
| `cli` | ripgrep, fzf, fd, bat, eza, jq, zoxide, atuin, lazygit |
| `git` | gh (GitHub CLI), glab (GitLab CLI) |
| `wm` | aerospace, yabai, skhd (macOS), hyprland (Linux) |
| `langs` | rust, go, node, python, lua, bun |
| `editors` | neovim, emacs, zed, helix |
| `shells` | fish, zsh, bash, nushell |
| `terminals` | wezterm, kitty, ghostty, alacritty |
| `devops` | docker, kubernetes, colima |
| `ai` | copilot-cli, claude-cli |
| `build` | cmake, make, ninja |

---

## **Common Workflows**

### **First Time Setup**
```bash
# 1. Edit config
nano sh/config.zsh

# 2. Preview
./sh/install-with-config.sh --dry-run

# 3. Install
./sh/install-with-config.sh
```

### **Add New Tool**
```bash
# 1. Add to config
echo "[newtool]=1" >> sh/config.zsh

# 2. Re-run (skips existing)
./sh/install-with-config.sh
```

### **New Machine**
```bash
# 1. Clone with config
git clone <repo>

# 2. Run installer
./sh/install-with-config.sh
```

### **Disable Tool**
```bash
# 1. Edit config
nano sh/config.zsh
# Set [tool]=0

# 2. No need to re-run
# (it won't uninstall, just skip on next run)
```

---

## **Decision Priority**

```
1. Category disabled?     → Skip all tools in category
2. Tool disabled?         → Skip that tool
3. Tool enabled/default?  → Install
```

**Example:**
```zsh
INSTALL_CATEGORIES=([cli]=0)   # Category OFF
CLI_TOOLS=([ripgrep]=1)        # Tool ON

Result: ripgrep NOT installed (category overrides)
```

```zsh
INSTALL_CATEGORIES=([cli]=1)   # Category ON
CLI_TOOLS=([ripgrep]=0)        # Tool OFF

Result: ripgrep NOT installed (tool setting wins)
```

---

## **File Locations**

```
sh/
├── config.zsh              ← Your preferences (EDIT THIS)
├── install-with-config.sh  ← Run this
├── git.sh                  ← Git tools
├── wm.sh                   ← Window managers
├── cli.sh                  ← CLI tools
└── common.sh               ← Shared utilities
```

---

## **Troubleshooting**

### **Config not working**
```bash
# Check if zsh is installed
which zsh

# Test config manually
zsh -c "source ./sh/config.zsh && export_config && env | grep INSTALL_"
```

### **Tool still prompts**
```bash
# Make sure category name is passed
confirm_install "tool" "category"  # ✅ Correct
confirm_install "tool"             # ❌ Wrong (will prompt)
```

### **Want to force reinstall**
```bash
# Uninstall first, then run installer
brew uninstall <tool>  # macOS
sudo apt remove <tool> # Ubuntu
./sh/install-with-config.sh
```

---

## **Environment Variables**

```bash
INSTALL_CONFIG_LOADED=1         # Config is active
INSTALL_NONINTERACTIVE=1        # Skip all prompts
INSTALL_CATEGORY_CLI=1          # Category enabled
INSTALL_CLI_RIPGREP=1           # Tool enabled
```

---

## **Tips**

✅ **DO:**
- Edit `config.zsh` for your setup
- Commit `config.zsh` to git
- Use `--dry-run` before installing
- Share config across machines

❌ **DON'T:**
- Modify category scripts directly
- Set contradicting values
- Expect config to uninstall tools

---

## **Getting Help**

```bash
./sh/install.sh --help                # Main installer help
cat sh/QUICK_START.md                 # Quick start guide
cat sh/CONFIG_GUIDE.md                # Full documentation
cat sh/VISUAL_EXAMPLE.md              # How it works
```

---

## **Quick Reference Card**

```
┌────────────────────────────────────────────┐
│  MOST COMMON COMMANDS                      │
├────────────────────────────────────────────┤
│  nano sh/config.zsh                        │  Edit preferences
│  ./sh/install-with-config.sh --dry-run    │  Preview
│  ./sh/install-with-config.sh              │  Install
└────────────────────────────────────────────┘
```
