# Documentation Index

All documentation for the new config-based installation system.

## **Start Here** 🚀

1. **[CHEATSHEET.md](CHEATSHEET.md)** - Quick commands and syntax
   - Most common commands
   - Config syntax
   - Quick reference card

2. **[QUICK_START.md](QUICK_START.md)** - Get started in 2 minutes
   - TL;DR version
   - Before/after comparison
   - Common scenarios

## **Understanding the System** 📚

3. **[VISUAL_EXAMPLE.md](VISUAL_EXAMPLE.md)** - See how it works
   - Step-by-step walkthrough
   - Visual flow diagrams
   - Before/after comparison
   - Real world examples

4. **[SYSTEM_EXPLAINED.md](../SYSTEM_EXPLAINED.md)** - Complete explanation
   - How the system works
   - Why config-based is better
   - Decision trees
   - Architecture diagrams

5. **[CONFIG_GUIDE.md](CONFIG_GUIDE.md)** - Complete configuration guide
   - All config options
   - Priority rules
   - Available categories
   - Troubleshooting

## **Quick Reference**

### **Most Common Commands**
```bash
nano sh/config.zsh                       # Edit preferences
./sh/install-with-config.sh --dry-run    # Preview
./sh/install-with-config.sh              # Install
```

### **Files You Should Know**
- `config.zsh` - Your preferences (EDIT THIS)
- `install-with-config.sh` - Run this
- `git.sh` - Git tools (gh, glab)
- `wm.sh` - Window managers (aerospace, hyprland)
- `cli.sh` - CLI tools (ripgrep, fzf, bat, etc.)

### **Old vs New System**

**OLD (Interactive):**
```bash
./sh/install.sh cli
# Answer Y/n 20+ times...
```

**NEW (Config-based):**
```bash
nano sh/config.zsh  # Set preferences once
./sh/install-with-config.sh  # No prompts!
```

## **Documentation Summary**

| File | Purpose | When to Read |
|------|---------|--------------|
| **CHEATSHEET.md** | Quick commands | When you need syntax |
| **QUICK_START.md** | Get started fast | First time using |
| **VISUAL_EXAMPLE.md** | See how it works | Want to understand |
| **SYSTEM_EXPLAINED.md** | Deep dive | Curious about internals |
| **CONFIG_GUIDE.md** | Complete reference | Configuring everything |

## **Common Questions**

### **How do I install tools?**
1. Edit `config.zsh` (set tools to 1 or 0)
2. Run `./sh/install-with-config.sh`

### **How do I exclude a tool?**
Set it to 0 in `config.zsh`:
```zsh
CLI_TOOLS=([bat]=0)  # Skip bat
```

### **Can I still use the old way?**
Yes! The old interactive system still works:
```bash
./sh/install.sh cli  # Interactive prompts
```

### **What categories exist?**
- `cli` - Modern CLI tools
- `git` - GitHub/GitLab CLI
- `wm` - Window managers
- `langs` - Programming languages
- `editors` - Text editors
- `shells` - Shells
- `terminals` - Terminal emulators
- `devops` - Docker, Kubernetes
- `ai` - AI tools
- `build` - Build tools

### **How do I add my own tool?**
1. Add to `config.zsh` in appropriate section
2. Update corresponding script (e.g., `cli.sh`)
3. Add `install_<tool>()` function
4. Add to `main()` array

## **Next Steps**

1. ✅ Read [QUICK_START.md](QUICK_START.md)
2. ✅ Edit `config.zsh`
3. ✅ Run `./sh/install-with-config.sh --dry-run`
4. ✅ Run `./sh/install-with-config.sh`
5. ✅ Commit `config.zsh` to git

---

**Need Help?**
- Quick syntax: [CHEATSHEET.md](CHEATSHEET.md)
- Understanding: [VISUAL_EXAMPLE.md](VISUAL_EXAMPLE.md)
- Everything: [CONFIG_GUIDE.md](CONFIG_GUIDE.md)
