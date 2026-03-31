# System Explanation - Visual Example

## **The Problem You Had**

Your old system worked like this:

```bash
# Each script has a main() function that calls EVERYTHING
main() {
  install_ripgrep
  install_fzf  
  install_bat
  install_eza
  # ... calls ALL tools
}
```

Each `install_*()` function would prompt:
```
Install ripgrep? (Y/n) _
```

**Problem**: No way to pre-define what you want. You had to answer prompts every time.

---

## **The Solution**

Now you have a **config file** that stores your preferences:

```zsh
# config.zsh
CLI_TOOLS=(
  [ripgrep]=1    # ✅ Install
  [fzf]=1        # ✅ Install  
  [bat]=0        # ❌ Skip
  [eza]=1        # ✅ Install
)
```

The installer reads this and skips prompts!

---

## **How It Works (Step by Step)**

### **Step 1: You Run Installer**

```bash
./sh/install-with-config.sh
```

### **Step 2: Config Gets Loaded**

```bash
# Installer runs:
source config.zsh
export_config

# This creates environment variables:
INSTALL_CONFIG_LOADED=1
INSTALL_CLI_RIPGREP=1
INSTALL_CLI_FZF=1
INSTALL_CLI_BAT=0        # ← bat is disabled!
INSTALL_CLI_EZA=1
```

### **Step 3: Category Script Runs**

```bash
# cli.sh runs:
main() {
  for tool in "ripgrep" "fzf" "bat" "eza"; do
    if confirm_install "$tool" "cli"; then
      install_$tool
    fi
  done
}
```

### **Step 4: confirm_install() Checks Config**

```bash
# For ripgrep:
confirm_install "ripgrep" "cli"
  → Checks INSTALL_CLI_RIPGREP = 1 ✅
  → Returns 0 (yes, install)
  → install_ripgrep runs

# For bat:
confirm_install "bat" "cli"
  → Checks INSTALL_CLI_BAT = 0 ❌
  → Returns 1 (no, skip)
  → install_bat DOES NOT run
```

### **Step 5: Output**

```
[INFO] Installing CLI Tools...
[✓] ripgrep installed
[✓] fzf installed
[SKIP] bat is disabled in config
[✓] eza installed
```

---

## **Visual Flow Diagram**

```
┌─────────────────┐
│  config.zsh     │
│  CLI_TOOLS=(    │
│   [bat]=0       │  ← You set this to 0
│  )              │
└────────┬────────┘
         │
         │ Loaded by install-with-config.sh
         ▼
┌─────────────────────────────┐
│  Environment Variables      │
│  INSTALL_CONFIG_LOADED=1    │
│  INSTALL_CLI_BAT=0          │  ← Exported
└────────┬────────────────────┘
         │
         │ Sourced by cli.sh
         ▼
┌─────────────────────────────┐
│  cli.sh main() function     │
│  for tool in ...; do        │
│    confirm_install "$tool"  │  ← Checks env vars
│  done                       │
└────────┬────────────────────┘
         │
         │ For bat:
         ▼
┌─────────────────────────────┐
│  confirm_install "bat"      │
│  → INSTALL_CLI_BAT = 0      │  ← Found it's disabled
│  → return 1 (skip)          │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│  install_bat DOES NOT RUN   │  ✅ Skipped!
└─────────────────────────────┘
```

---

## **Comparison: Before vs After**

### **BEFORE (Interactive)**

```bash
$ ./sh/cli.sh

Install ripgrep? (Y/n) y
[✓] ripgrep installed

Install fzf? (Y/n) y
[✓] fzf installed

Install bat? (Y/n) n     ← You type 'n' here
[SKIP] Skipped bat

Install eza? (Y/n) y
[✓] eza installed

# Problem: Must answer EVERY TIME you run it
```

### **AFTER (Config-Based)**

```bash
$ nano sh/config.zsh
# Set CLI_TOOLS=([bat]=0) once

$ ./sh/install-with-config.sh

[✓] ripgrep installed
[✓] fzf installed
[SKIP] bat is disabled in config  ← No prompt!
[✓] eza installed

# Benefit: No prompts, remembers your choice
```

---

## **Real World Example**

### **Scenario: New Machine Setup**

**Old way (painful):**
```bash
# On new machine
./sh/install.sh --all
# Now answer Y/n 50+ times...
```

**New way (easy):**
```bash
# On old machine (once)
nano sh/config.zsh
# Set all preferences
git add sh/config.zsh
git commit -m "My install preferences"

# On new machine
git clone <repo>
./sh/install-with-config.sh
# Done! Zero prompts, same exact setup
```

---

## **Key Insight**

The **same scripts** work in **three modes**:

1. **Interactive**: No config → prompts you
2. **Non-interactive**: `INSTALL_NONINTERACTIVE=1` → installs all
3. **Config-based**: Config loaded → reads preferences

It's all controlled by the `confirm_install()` function checking environment variables!

---

## **Summary**

```
config.zsh (your preferences)
    ↓
install-with-config.sh (loads config)
    ↓
Exports INSTALL_* env variables
    ↓
cli.sh, git.sh, wm.sh, etc. (category scripts)
    ↓
confirm_install() checks env variables
    ↓
Installs only what's enabled
```

**Bottom Line**: Edit config once, run installer anytime, no prompts! 🎉
