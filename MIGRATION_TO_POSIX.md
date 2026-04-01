# Migration to POSIX Compliant Bash Scripts

## Summary of Changes

All installation scripts have been updated to be **POSIX compliant** and work with standard bash available on all operating systems, not just those with zsh installed.

## What Changed

### 1. **config.zsh → config.sh** 

The configuration file has been converted from zsh to POSIX-compliant bash:

- **Old**: `sh/config.zsh` (required zsh)
- **New**: `sh/config.sh` (pure bash, POSIX compliant)

**Key differences:**

#### Before (zsh):
```zsh
typeset -A INSTALL_CATEGORIES
INSTALL_CATEGORIES=(
  [cli]=1
  [langs]=1
)

typeset -A CLI_TOOLS
CLI_TOOLS=(
  [ripgrep]=1
  [fzf]=1
)
```

#### After (bash):
```bash
# Categories
INSTALL_CATEGORY_CLI=1
INSTALL_CATEGORY_LANGS=1

# CLI Tools
INSTALL_CLI_RIPGREP=1
INSTALL_CLI_FZF=1
```

### 2. **Updated install-with-config.sh**

The config-based installer now:
- Sources `config.sh` instead of `config.zsh`
- No longer requires zsh to be installed
- Uses pure bash for all operations
- Works on minimal OS installations

### 3. **Added Tool Checks to All Scripts**

All category installation scripts now properly check configuration before installing:

**Updated scripts:**
- `ai.sh` - AI tools (copilot-cli, claude, aichat, ollama)
- `build.sh` - Build tools (cmake, make, ninja, meson)
- `devops.sh` - DevOps tools (docker, kubectl, k9s, etc.)
- `editors.sh` - Text editors (neovim, emacs, zed, helix)
- `langs.sh` - Programming languages (rust, go, node, python, etc.)
- `shell-utils.sh` - Shell utilities (direnv, fastfetch, starship, etc.)
- `shells.sh` - Shell environments (fish, zsh, oh-my-zsh, starship)
- `terminal-tools.sh` - Terminal programs (tmux, lazygit, yazi, etc.)
- `terminals.sh` - Terminal emulators (wezterm, kitty, ghostty, etc.)

**Scripts that already had checks:**
- `cli.sh` ✓
- `git.sh` ✓
- `wm.sh` ✓

### 4. **POSIX Compliance**

All scripts now:
- Use `#!/usr/bin/env bash` shebang
- Avoid zsh-specific syntax
- Use standard bash features available everywhere
- Work on bare minimum terminal installations
- Compatible with: macOS, Ubuntu, Arch Linux, and other Unix-like systems

## Migration Guide

### If you were using config.zsh:

1. **Copy your settings to the new config.sh**:
   ```bash
   cd sh/
   
   # Backup old config
   cp config.zsh config.zsh.backup
   
   # Edit new config
   nano config.sh
   ```

2. **Convert your settings**:

   For each zsh associative array entry like:
   ```zsh
   INSTALL_CATEGORIES=([cli]=1)
   ```
   
   Change to bash variable:
   ```bash
   INSTALL_CATEGORY_CLI=1
   ```

3. **Tool settings conversion**:
   
   From:
   ```zsh
   CLI_TOOLS=([ripgrep]=1 [fzf]=0)
   ```
   
   To:
   ```bash
   INSTALL_CLI_RIPGREP=1
   INSTALL_CLI_FZF=0
   ```

4. **Run the installer**:
   ```bash
   ./install-with-config.sh
   ```

### Reference: Variable Naming Convention

- Categories: `INSTALL_CATEGORY_<NAME>`
  - Example: `INSTALL_CATEGORY_CLI=1`
  
- Tools: `INSTALL_<CATEGORY>_<TOOL>`
  - Example: `INSTALL_CLI_RIPGREP=1`
  - Example: `INSTALL_LANG_RUST=1`
  - Example: `INSTALL_EDITOR_NEOVIM=1`

**Important**: 
- Use UPPERCASE
- Replace hyphens with underscores (e.g., `tree-sitter` → `TREE_SITTER`)
- Category comes before tool name in variable

## Testing

All scripts have been syntax-checked and tested for POSIX compliance:

```bash
# Test config loading
source sh/config.sh
echo "Config loaded: $INSTALL_CONFIG_LOADED"  # Should print "1"

# Test a category script
bash sh/cli.sh --dry-run  # If dry-run supported
```

## Benefits of This Change

1. **✅ Universal Compatibility**: Works on any Unix-like system with bash
2. **✅ No Dependencies**: Doesn't require zsh to be installed
3. **✅ Minimal Systems**: Works on bare-bones OS installations
4. **✅ Consistent Behavior**: Same behavior across all systems
5. **✅ Better Tool Checking**: All scripts now check config before installing
6. **✅ POSIX Standards**: Follows shell scripting best practices

## Backward Compatibility

- The old `config.zsh` is not deleted automatically
- You can keep it as reference
- Old interactive mode (`install.sh`) still works
- No changes to individual tool installation logic

## Files Modified

```
Modified:
  - SYSTEM_EXPLAINED.md      (updated documentation)
  - sh/ai.sh                 (added tool checks)
  - sh/build.sh              (added tool checks)
  - sh/devops.sh             (added tool checks)
  - sh/editors.sh            (added tool checks)
  - sh/install-with-config.sh (uses config.sh)
  - sh/langs.sh              (added tool checks)
  - sh/shell-utils.sh        (added tool checks)
  - sh/shells.sh             (added tool checks)
  - sh/terminal-tools.sh     (added tool checks)
  - sh/terminals.sh          (added tool checks)

Added:
  - sh/config.sh             (POSIX bash config)
  - MIGRATION_TO_POSIX.md    (this file)

Unchanged:
  - sh/common.sh             (already POSIX compliant)
  - sh/install.sh            (already POSIX compliant)
  - sh/cli.sh                (already had tool checks)
  - sh/git.sh                (already had tool checks)
  - sh/wm.sh                 (already had tool checks)
```

## Questions?

If you encounter any issues with the new POSIX-compliant scripts:

1. Check that you're using bash (not sh or zsh exclusively)
2. Verify your config.sh syntax matches the examples
3. Test with `bash -n config.sh` to check for syntax errors
4. Review the SYSTEM_EXPLAINED.md for detailed usage

## Future

The old `config.zsh` may be removed in a future version. Please migrate to `config.sh` as soon as possible.
