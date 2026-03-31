# Installation System - Complete Overview

## **Three-Layer Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│                      LAYER 1: CLI FLAGS                      │
│                    (Highest Priority)                        │
├─────────────────────────────────────────────────────────────┤
│  ./sh/install-with-config.sh cli git --exclude devops       │
│                                                              │
│  Override Modes:                                            │
│  • Positional args (cli git) → Install only these           │
│  • --exclude/-e devops       → Skip these                   │
│  • --only/-o cli             → Explicit "only"              │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼ If no flags, use...
┌─────────────────────────────────────────────────────────────┐
│                   LAYER 2: CONFIG FILE                       │
│                   (Default Settings)                         │
├─────────────────────────────────────────────────────────────┤
│  sh/config.zsh                                              │
│                                                              │
│  INSTALL_CATEGORIES=(                                       │
│    [cli]=1      # Enable CLI tools                          │
│    [git]=1      # Enable git tools                          │
│    [devops]=0   # Disable DevOps                            │
│  )                                                           │
│                                                              │
│  CLI_TOOLS=(                                                │
│    [ripgrep]=1  # Install ripgrep                           │
│    [bat]=0      # Skip bat                                  │
│  )                                                           │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼ If config not loaded, fallback to...
┌─────────────────────────────────────────────────────────────┐
│              LAYER 3: INTERACTIVE PROMPTS                    │
│                    (Original System)                         │
├─────────────────────────────────────────────────────────────┤
│  ./sh/install.sh cli                                        │
│                                                              │
│  Install ripgrep? (Y/n) _                                   │
│  Install fzf? (Y/n) _                                       │
│  ...                                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## **Decision Flow**

```
User runs: ./sh/install-with-config.sh cli git
                     │
                     ▼
          ┌──────────────────────┐
          │   Load config.zsh    │
          │   (Set defaults)     │
          └──────────┬───────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │  CLI flags present?  │
          └──────────┬───────────┘
                     │
              ┌──────┴──────┐
              │             │
            YES            NO
              │             │
              ▼             ▼
     ┌────────────────┐  ┌────────────────┐
     │ Override config│  │   Use config   │
     │ Install: cli,  │  │   as-is        │
     │         git    │  │                │
     └────────┬───────┘  └────────┬───────┘
              │                   │
              └─────────┬─────────┘
                        │
                        ▼
              ┌───────────────────┐
              │  For each tool:   │
              │  confirm_install()│
              └─────────┬─────────┘
                        │
                        ▼
              ┌───────────────────┐
              │  Check if tool    │
              │  is enabled       │
              └─────────┬─────────┘
                        │
                ┌───────┴───────┐
                │               │
             ENABLED         DISABLED
                │               │
                ▼               ▼
        ┌──────────────┐  ┌──────────┐
        │ install_tool │  │   Skip   │
        └──────────────┘  └──────────┘
```

---

## **Priority Matrix**

| Flag | Config | Result | Why |
|------|--------|--------|-----|
| `cli` | cli=0 | Install cli | Flag overrides config |
| `--exclude cli` | cli=1 | Skip cli | Flag overrides config |
| None | cli=1 | Install cli | Use config |
| None | cli=0 | Skip cli | Use config |
| `cli git` | cli=0, git=0, wm=1 | Install cli, git only | Flags override all |

---

## **All Available Commands**

### **Config-Based (Best)**

```bash
# Use config exactly
./sh/install-with-config.sh

# Override: install only these
./sh/install-with-config.sh cli git wm

# Override: exclude from config
./sh/install-with-config.sh --exclude devops
./sh/install-with-config.sh -e devops -e ai

# Override: explicit only
./sh/install-with-config.sh --only cli

# Preview
./sh/install-with-config.sh --dry-run
./sh/install-with-config.sh --dry-run cli
```

### **Interactive (Original)**

```bash
# Interactive menu
./sh/install.sh

# Install category with prompts
./sh/install.sh cli

# Install all with prompts
./sh/install.sh --all

# List available
./sh/install.sh --list

# Exclude with prompts
./sh/install.sh --exclude docker
```

### **Non-Interactive (All-or-Nothing)**

```bash
# Install everything, no prompts
INSTALL_NONINTERACTIVE=1 ./sh/install.sh --all

# Install category, no prompts
INSTALL_NONINTERACTIVE=1 ./sh/install.sh cli
```

### **Direct Category Scripts**

```bash
# Run individual category scripts
./sh/cli.sh        # CLI tools
./sh/git.sh        # Git tools
./sh/wm.sh         # Window managers
./sh/editors.sh    # Editors
./sh/langs.sh      # Languages
```

---

## **When to Use Each Mode**

| Mode | Command | Use Case |
|------|---------|----------|
| **Config** | `./sh/install-with-config.sh` | Regular use, reproducible |
| **Config + Flags** | `./sh/install-with-config.sh cli` | One-off variations |
| **Interactive** | `./sh/install.sh cli` | First time, exploring |
| **Non-Interactive** | `INSTALL_NONINTERACTIVE=1 ./sh/install.sh --all` | CI/CD, scripts |
| **Direct** | `./sh/cli.sh` | Debug, single category |

---

## **Complete File Structure**

```
install/
├── SYSTEM_EXPLAINED.md        ← How everything works
├── install                    ← Old system (legacy)
│
├── sh/                        ← New system (use this!)
│   │
│   ├── config.zsh             ← YOUR CONFIG FILE ⭐
│   ├── install-with-config.sh ← Config installer ⭐
│   ├── install.sh             ← Interactive installer
│   ├── common.sh              ← Shared utilities
│   │
│   ├── git.sh                 ← Git tools (gh, glab)
│   ├── wm.sh                  ← Window managers
│   ├── cli.sh                 ← CLI tools
│   ├── langs.sh               ← Languages
│   ├── editors.sh             ← Editors
│   ├── shells.sh              ← Shells
│   ├── terminals.sh           ← Terminals
│   ├── devops.sh              ← DevOps
│   ├── build.sh               ← Build tools
│   ├── shell-utils.sh         ← Shell utilities
│   ├── ai.sh                  ← AI tools
│   ├── terminal-tools.sh      ← Terminal programs
│   │
│   ├── CHEATSHEET.md          ← Quick reference
│   ├── QUICK_START.md         ← 2-minute guide
│   ├── CONFIG_GUIDE.md        ← Full config guide
│   ├── FLAG_OVERRIDES.md      ← Flag override examples
│   ├── VISUAL_EXAMPLE.md      ← Visual walkthrough
│   ├── SYSTEM_OVERVIEW.md     ← This file
│   └── README_DOCS.md         ← Documentation index
│
└── installs/                  ← Old system directories
    ├── git                    ← Original scripts
    ├── wm
    └── ...
```

---

## **Recommended Workflow**

### **Step 1: Setup Config (Once)**

```bash
cd install/sh
nano config.zsh

# Set your preferences:
INSTALL_CATEGORIES=([cli]=1 [git]=1 [wm]=1 [devops]=0)
CLI_TOOLS=([ripgrep]=1 [fzf]=1 [bat]=1)
```

### **Step 2: Install (Anytime)**

```bash
# Regular use - no prompts!
./sh/install-with-config.sh

# Override for specific machine
./sh/install-with-config.sh --exclude devops
```

### **Step 3: Update (As Needed)**

```bash
# Add new tool to config
nano sh/config.zsh

# Re-run (skips installed)
./sh/install-with-config.sh
```

---

## **Quick Decision Guide**

```
Need reproducible setup?
  └─> Use config.zsh + install-with-config.sh

One-off override?
  └─> Add flags: ./sh/install-with-config.sh cli

First time exploring?
  └─> Use interactive: ./sh/install.sh

Machine-specific variation?
  └─> Use flags: ./sh/install-with-config.sh --exclude devops

CI/CD script?
  └─> Non-interactive: INSTALL_NONINTERACTIVE=1 ./sh/install.sh --all
```

---

## **Summary**

✅ **3 Layers**: Flags > Config > Interactive  
✅ **Config sets defaults**: Edit once, use everywhere  
✅ **Flags override**: Quick machine-specific changes  
✅ **No prompts**: Fast, reproducible installations  
✅ **Backward compatible**: Old system still works  

**Best Practice**: Config for defaults, flags for variations! 🎉
