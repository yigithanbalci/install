# Installation System - Complete Explanation

## **Overview: How The Current System Works**

Your installation system has **3 modes** of operation:

```
┌─────────────────────────────────────────────────────────────┐
│                    INSTALLATION MODES                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. INTERACTIVE (Original)                                   │
│     └─> Prompts Y/n for each tool                           │
│     └─> Usage: ./sh/install.sh cli                          │
│                                                              │
│  2. NON-INTERACTIVE (All-or-nothing)                         │
│     └─> Installs everything, no prompts                     │
│     └─> Usage: INSTALL_NONINTERACTIVE=1 ./sh/install.sh     │
│                                                              │
│  3. CONFIG-BASED (NEW ✨)                                    │
│     └─> Uses config.zsh to decide what to install           │
│     └─> Usage: ./sh/install-with-config.sh                  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## **How Each Script Works**

### **Architecture**

```
sh/
├── common.sh              ← Shared utilities (OS detection, pkg_install, confirm_install)
├── config.zsh             ← YOUR CONFIG FILE (what to install)
├── install.sh             ← Main orchestrator (interactive)
├── install-with-config.sh ← Config-based orchestrator (NEW)
│
├── cli.sh                 ← Individual category scripts
├── git.sh                 ← Each has install_<tool>() functions
├── wm.sh                  ← All follow same pattern
├── editors.sh
├── langs.sh
└── ...
```

### **Script Flow**

Every category script follows this pattern:

```bash
#!/usr/bin/env bash
source "$SCRIPT_DIR/common.sh"  # 1. Load utilities

# 2. Define install functions (one per tool)
install_ripgrep() {
  if is_installed ripgrep; then return 0; fi
  case "$OS" in
    macos) pkg_install ripgrep ;;
    ubuntu) pkg_install ripgrep ;;
    arch) pkg_install ripgrep ;;
  esac
}

install_fzf() { ... }
install_bat() { ... }

# 3. Main function orchestrates installation
main() {
  local tools=("ripgrep" "fzf" "bat")
  
  for tool in "${tools[@]}"; do
    if confirm_install "$tool" "cli"; then  # ← THE MAGIC HAPPENS HERE
      install_$tool || log_error "Failed"
    fi
  done
}

main  # 4. Execute
```

---

## **The Magic: `confirm_install()` Function**

This function decides whether to install a tool:

```bash
confirm_install() {
  local program="$1"    # e.g., "ripgrep"
  local category="$2"   # e.g., "cli"
  
  # MODE 1: Config-based (checks config.zsh)
  if [[ "${INSTALL_CONFIG_LOADED:-0}" == "1" ]]; then
    # Check if category is enabled
    if category is disabled in config; then
      return 1  # Skip
    fi
    
    # Check if specific tool is enabled
    if tool is disabled in config; then
      return 1  # Skip
    fi
    
    return 0  # Install
  fi
  
  # MODE 2: Non-interactive (install everything)
  if [[ "${INSTALL_NONINTERACTIVE:-0}" == "1" ]]; then
    return 0  # Install
  fi
  
  # MODE 3: Interactive (prompt user)
  read -p "Install $program? (Y/n) "
  # Returns based on user input
}
```

**Key insight**: The same script can work in all 3 modes just by changing environment variables!

---

## **How Config System Works**

### **1. You Edit `config.zsh`**

```zsh
INSTALL_CATEGORIES=(
  [cli]=1     # Enable entire CLI category
  [git]=1     # Enable git category
  [devops]=0  # Disable DevOps category
)

CLI_TOOLS=(
  [ripgrep]=1  # Install ripgrep
  [bat]=0      # Don't install bat
)

GIT_TOOLS=(
  [gh]=1       # Install GitHub CLI
  [glab]=1     # Install GitLab CLI
)
```

### **2. Config Gets Exported as Environment Variables**

When you run `./sh/install-with-config.sh`, it does:

```bash
# Load config
source config.zsh
export_config  # Exports as INSTALL_CATEGORY_CLI=1, INSTALL_CLI_RIPGREP=1, etc.

# Set flag
export INSTALL_CONFIG_LOADED=1

# Run category scripts
bash cli.sh
bash git.sh
# etc...
```

### **3. Scripts Read Environment Variables**

When `cli.sh` runs:

```bash
confirm_install "ripgrep" "cli"
  ↓
  Checks: INSTALL_CATEGORY_CLI = 1  ✓
  Checks: INSTALL_CLI_RIPGREP = 1   ✓
  Returns: 0 (install)
  ↓
install_ripgrep  # Executes
```

If bat is disabled:

```bash
confirm_install "bat" "cli"
  ↓
  Checks: INSTALL_CATEGORY_CLI = 1  ✓
  Checks: INSTALL_CLI_BAT = 0       ✗
  Returns: 1 (skip)
  ↓
# install_bat never runs
```

---

## **Why This Is Better**

### **Before (Interactive Mode)**

```bash
$ ./sh/install.sh cli
Install ripgrep? (Y/n) y
Install fzf? (Y/n) y
Install fd? (Y/n) y
Install bat? (Y/n) n
Install eza? (Y/n) y
Install jq? (Y/n) y
Install zoxide? (Y/n) y
Install atuin? (Y/n) n
Install tldr? (Y/n) y
Install stow? (Y/n) y
Install tree-sitter? (Y/n) y
Install lazygit? (Y/n) y
Install television? (Y/n) n
Install sesh? (Y/n) y

[5 minutes later...]
```

**Problems:**
- ❌ Can't save preferences
- ❌ Must answer every time
- ❌ Error-prone (miss one, start over)
- ❌ Can't reproduce on another machine

### **After (Config Mode)**

```bash
# Edit config once
$ nano sh/config.zsh
# Set CLI_TOOLS=([ripgrep]=1 [fzf]=1 [bat]=0 ...)

$ ./sh/install-with-config.sh
✓ Configuration loaded
✓ Enabled categories: cli, git, wm
✓ ripgrep installed
✓ fzf installed
✓ bat (skipped - disabled)
✓ eza installed
...
All installations complete!
```

**Benefits:**
- ✅ Save preferences in file
- ✅ No prompts
- ✅ Reproducible
- ✅ Version controlled
- ✅ Share across machines

---

## **Practical Usage Examples**

### **Example 1: First Time Setup**

```bash
# Clone repo
git clone <repo>
cd install/sh

# Edit config for your preferences
nano config.zsh

# Preview what will install
./install-with-config.sh --dry-run

# Install
./install-with-config.sh
```

### **Example 2: Add New Tool Later**

```bash
# Edit config (add new tool)
nano config.zsh
# Set: CLI_TOOLS=([newtool]=1 ...)

# Re-run (skips already-installed tools)
./install-with-config.sh
```

### **Example 3: New Machine with Same Setup**

```bash
# Copy config from old machine
scp oldmachine:~/devenv/install/sh/config.zsh ./sh/

# Run on new machine
./sh/install-with-config.sh

# Same environment, zero prompts!
```

### **Example 4: Work vs Personal Config**

```bash
# Keep two configs
cp config.zsh config-work.zsh
cp config.zsh config-personal.zsh

# Edit each differently
nano config-work.zsh     # Disable personal tools
nano config-personal.zsh # Enable everything

# Use appropriate one
ln -sf config-work.zsh config.zsh
./install-with-config.sh
```

---

## **Complete File Structure**

```
install/
├── install                    ← Old system (legacy)
├── installs/                  ← Old system directories
│   ├── git                    ← Original git install script
│   ├── wm                     ← Original wm install script
│   └── ...
│
├── sh/                        ← New system (recommended)
│   ├── common.sh              ← Utilities (OS detect, install, confirm)
│   ├── config.zsh             ← YOUR CONFIG FILE ⭐
│   │
│   ├── install.sh             ← Main orchestrator (interactive)
│   ├── install-with-config.sh ← Config orchestrator (NEW)
│   │
│   ├── cli.sh                 ← Category scripts
│   ├── git.sh                 ← (ripgrep, fzf, bat, gh, glab, etc.)
│   ├── wm.sh                  ← (aerospace, hyprland, etc.)
│   ├── editors.sh             ← (neovim, emacs, zed)
│   ├── langs.sh               ← (rust, go, node, python)
│   └── ...
│   │
│   ├── CONFIG_GUIDE.md        ← Full documentation
│   ├── QUICK_START.md         ← Quick reference
│   └── SYSTEM_EXPLAINED.md    ← This file
│
└── README.md
```

---

## **Decision Tree: Which Mode to Use?**

```
┌─────────────────────────────────────────┐
│ Do you want to save your preferences?   │
└────────┬─────────────────────┬──────────┘
         │                     │
      YES ├─────────────────┐  NO
         │                 │  │
         ▼                 ▼  ▼
   ┌─────────────┐   ┌──────────────┐
   │ CONFIG MODE │   │ INTERACTIVE  │
   │   (Best)    │   │  (Original)  │
   └─────────────┘   └──────────────┘
   
   Use:               Use:
   ./install-with-    ./install.sh cli
   config.sh          
                      OR
   Benefits:          
   • Reproducible    INSTALL_NONINTERACTIVE=1
   • Fast            ./install.sh --all
   • Shareable       
   • No prompts      Benefits:
                     • Simple
                     • One-time use
```

---

## **Summary**

1. **Old Way**: Each script prompts Y/n for every tool
2. **Problem**: Can't save preferences, tedious to repeat
3. **Solution**: Config file (`config.zsh`) stores what you want
4. **How It Works**: 
   - Edit `config.zsh` once
   - Run `./install-with-config.sh`
   - Scripts read config automatically via environment variables
   - No prompts, installs only enabled tools
5. **Benefits**: Reproducible, fast, shareable, version-controlled

**Bottom line**: Edit `config.zsh`, run installer, done! 🎉
