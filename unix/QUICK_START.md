# Quick Start - Config-Based Installation

## **TL;DR**

Instead of answering Y/n prompts for every tool, edit a config file once:

```bash
# 1. Edit what you want
nano sh/config.zsh

# 2. Install
./sh/install-with-config.sh
```

---

## **How to Use**

### **1. Edit `config.zsh`**

Set tools to `1` (install) or `0` (skip):

```zsh
# Categories
INSTALL_CATEGORIES=(
  [cli]=1        # ✅ Install CLI tools
  [devops]=0     # ❌ Skip DevOps tools
  [git]=1        # ✅ Install git tools
)

# Individual tools
CLI_TOOLS=(
  [ripgrep]=1    # ✅ Install
  [fzf]=1        # ✅ Install
  [bat]=0        # ❌ Skip
)

GIT_TOOLS=(
  [gh]=1         # ✅ GitHub CLI
  [glab]=1       # ✅ GitLab CLI
)
```

### **2. Preview (Optional)**

```bash
./sh/install-with-config.sh --dry-run
```

### **3. Install**

```bash
./sh/install-with-config.sh
```

Done! No prompts, installs only what you enabled.

---

## **What Changed?**

### **Before (Old Way)**

```bash
$ ./sh/install.sh cli
Install ripgrep? (Y/n) y
Install fzf? (Y/n) y
Install bat? (Y/n) n
Install eza? (Y/n) y
... (50+ prompts later)
```

### **After (New Way)**

```bash
$ ./sh/install-with-config.sh
✓ Configuration loaded
✓ ripgrep installed
✓ fzf installed
✓ eza installed
All installations complete!
```

No prompts! Config file controls everything.

---

## **Common Scenarios**

### **Minimal Setup**

```zsh
# Only essentials
INSTALL_CATEGORIES=([cli]=1 [langs]=1 [editors]=1 [git]=1)
CLI_TOOLS=([ripgrep]=1 [fzf]=1 [bat]=1 [lazygit]=1)
LANGS=([node]=1 [python]=1)
EDITORS=([neovim]=1)
GIT_TOOLS=([gh]=1)
```

### **Full Setup**

```zsh
# Everything enabled
INSTALL_CATEGORIES=(
  [cli]=1 [langs]=1 [editors]=1 [shells]=1
  [terminals]=1 [terminal-tools]=1 [devops]=1
  [build]=1 [shell-utils]=1 [ai]=1 [git]=1 [wm]=1
)
```

### **Work Machine**

```zsh
# No personal tools
INSTALL_CATEGORIES=(
  [cli]=1 [langs]=1 [editors]=1 [git]=1 [devops]=1
  [wm]=0 [ai]=0 [terminals]=0  # Skip personal stuff
)
```

---

## **Categories Available**

- `cli` - ripgrep, fzf, bat, eza, zoxide, etc.
- `langs` - rust, go, node, python
- `editors` - neovim, emacs, zed
- `git` - gh (GitHub CLI), glab (GitLab CLI)
- `wm` - aerospace, hyprland, yabai
- `shells` - fish, zsh, bash
- `terminals` - wezterm, kitty, ghostty
- `devops` - docker, kubernetes, colima
- `ai` - copilot-cli, claude

See `CONFIG_GUIDE.md` for complete list.

---

## **Old Way Still Works**

If you prefer prompts:

```bash
./sh/install.sh cli              # Interactive prompts
./sh/install.sh --all            # Install everything with prompts
INSTALL_NONINTERACTIVE=1 ./sh/install.sh --all  # No prompts, install all
```

But config-based is faster and reproducible!
