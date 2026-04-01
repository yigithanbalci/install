# Flag Override Examples

The config-based installer now supports **flag overrides**! This means you can:
1. Set defaults in `config.zsh`
2. Override those defaults with CLI flags

## **Priority Order**

```
CLI Flags > Config File > Defaults
```

## **All Override Options**

### **1. Positional Categories (Override to Only Install These)**

```bash
# Install ONLY cli and git (ignores all config settings)
./sh/install-with-config.sh cli git

# Install ONLY langs
./sh/install-with-config.sh langs

# Multiple categories
./sh/install-with-config.sh cli langs editors git
```

**Result**: Installs only specified categories, ignoring config.

---

### **2. --exclude / -e (Exclude Specific Categories)**

```bash
# Use config, but SKIP devops
./sh/install-with-config.sh --exclude devops

# Exclude multiple
./sh/install-with-config.sh -e devops -e ai -e docker

# Short form
./sh/install-with-config.sh -e devops
```

**Result**: Installs everything from config EXCEPT excluded categories.

---

### **3. --only / -o (Install Only Specific Categories)**

```bash
# Install ONLY cli tools
./sh/install-with-config.sh --only cli

# Multiple with --only
./sh/install-with-config.sh -o cli -o git -o wm
```

**Result**: Same as positional args, but more explicit.

---

### **4. Combining Flags**

```bash
# Install cli and langs, but exclude devops
./sh/install-with-config.sh cli langs -e devops

# Dry-run with overrides
./sh/install-with-config.sh --dry-run --only cli
```

---

## **Real-World Scenarios**

### **Scenario 1: Quick Dev Setup (Minimal Tools)**

Config has everything enabled, but you want only essentials:

```bash
./sh/install-with-config.sh cli langs editors git
```

### **Scenario 2: Work Machine (No Personal Tools)**

```bash
# Config has personal tools, exclude them for work
./sh/install-with-config.sh --exclude wm --exclude ai
```

### **Scenario 3: Testing New Category**

```bash
# Test git tools without affecting anything else
./sh/install-with-config.sh --dry-run git
```

### **Scenario 4: Fresh Machine (Use Config, Skip Docker)**

```bash
# Config is perfect, but skip docker on this machine
./sh/install-with-config.sh --exclude devops
```

### **Scenario 5: CI/CD (Only Build Tools)**

```bash
# Install only what's needed for CI
./sh/install-with-config.sh build langs
```

---

## **Visual Examples**

### **Example 1: Config Default**

```zsh
# config.zsh
INSTALL_CATEGORIES=(
  [cli]=1
  [git]=1
  [devops]=1
  [ai]=1
)
```

```bash
# Run without flags - uses config
./sh/install-with-config.sh

# Result: cli, git, devops, ai installed
```

---

### **Example 2: Override with Positional Args**

```bash
# Override: Only install cli
./sh/install-with-config.sh cli

# Result: ONLY cli installed (config ignored)
```

---

### **Example 3: Exclude from Config**

```bash
# Use config, but skip devops and ai
./sh/install-with-config.sh -e devops -e ai

# Result: cli, git installed (devops, ai skipped)
```

---

## **Decision Matrix**

| Command | Config Says | Result |
|---------|-------------|--------|
| `./sh/install-with-config.sh` | cli=1, git=1, wm=0 | Install: cli, git |
| `./sh/install-with-config.sh cli` | cli=1, git=1, wm=0 | Install: cli only |
| `./sh/install-with-config.sh -e git` | cli=1, git=1, wm=0 | Install: cli |
| `./sh/install-with-config.sh wm` | cli=1, git=1, wm=0 | Install: wm (override!) |
| `./sh/install-with-config.sh --only wm` | cli=1, git=1, wm=0 | Install: wm (override!) |

**Key Insight**: Flags ALWAYS override config!

---

## **Common Patterns**

### **Pattern 1: "Config + Exclude"**

Use config as template, exclude problematic tools:

```bash
# Config enables everything
# But exclude docker on macOS M1
./sh/install-with-config.sh --exclude devops
```

### **Pattern 2: "Minimal + Add"**

Start minimal, add specific tools:

```bash
# Install only these three
./sh/install-with-config.sh cli git editors
```

### **Pattern 3: "Test Before Full Install"**

Test specific category first:

```bash
# Dry-run new git tools
./sh/install-with-config.sh --dry-run git

# If good, install just that
./sh/install-with-config.sh git

# Then install rest
./sh/install-with-config.sh
```

---

## **Interactive vs Config vs Flags**

| Mode | Command | When to Use |
|------|---------|-------------|
| **Interactive** | `./sh/install.sh cli` | First time, exploring tools |
| **Config** | `./sh/install-with-config.sh` | Regular use, reproducible |
| **Config + Flags** | `./sh/install-with-config.sh cli` | One-off overrides |

---

## **Pro Tips**

1. **Set config as "full install"**, use flags to exclude on specific machines
2. **Always test with --dry-run** before running
3. **Commit config.zsh** to git, use flags for machine-specific changes
4. **Use positional args** for quick one-off installs
5. **Use --exclude** when you want "everything except X"

---

## **Complete Flag Reference**

```bash
# No flags - use config exactly
./sh/install-with-config.sh

# Positional categories - override to install only these
./sh/install-with-config.sh cli git wm

# --only / -o - explicit form of positional args
./sh/install-with-config.sh --only cli
./sh/install-with-config.sh -o cli -o git

# --exclude / -e - use config, but skip these
./sh/install-with-config.sh --exclude devops
./sh/install-with-config.sh -e devops -e ai

# --dry-run / -d - preview without installing
./sh/install-with-config.sh --dry-run
./sh/install-with-config.sh -d cli

# Combining
./sh/install-with-config.sh cli git -e devops --dry-run
./sh/install-with-config.sh -o cli --exclude ai -d
```

---

## **Summary**

✅ **Config sets defaults** - Edit `config.zsh` once  
✅ **Flags override** - Quick machine-specific changes  
✅ **Reproducible** - Config in git, flags for variations  
✅ **Flexible** - Mix and match as needed  

**Best Practice**: 
1. Set config for "ideal setup"
2. Use flags for deviations
3. Don't edit config for one-off changes
