# Unified Entry Point - Summary

## What Changed

### ✅ Consolidated Installation System

**Before:**
- Two separate scripts: `install.sh` and `install-with-config.sh`
- No unified entry point
- Confusing for users which one to use

**After:**
- **Single unified script**: `sh/install.sh` handles ALL three modes
- **Root entry point**: `unix.sh` at repository root
- Simple, clear interface

## The Three Modes (All in One Script)

### 1. Config Mode (`--use-config`)
```bash
./unix.sh --use-config
# Uses config.sh for all decisions
# No prompts, fully automated
```

### 2. Interactive Mode (default)
```bash
./unix.sh
# Prompts for each category/tool
# Good for first-time setup
```

### 3. CLI Arguments Mode
```bash
./unix.sh cli langs
# Install specific categories from command line
# Good for automation
```

## Entry Points

### Primary: `unix.sh` (Repository Root)
```bash
# Main entry point - use this!
./unix.sh [options] [categories...]

# Examples:
./unix.sh --use-config              # Config mode
./unix.sh                           # Interactive
./unix.sh cli langs                 # Specific categories
./unix.sh --use-config -e devops    # Config + override
```

### Alternative: `sh/install.sh`
```bash
# Can also be called directly
cd sh/
./install.sh --use-config
./install.sh cli langs
```

## Architecture

```
install/
├── unix.sh                   ← ROOT ENTRY POINT
│                                (delegates to sh/install.sh)
│
└── sh/
    ├── install.sh            ← UNIFIED INSTALLER
    │                            (handles all 3 modes)
    │
    ├── config.sh             ← Configuration
    │
    ├── install-with-config.sh  ← DEPRECATED
    │                              (redirects to install.sh --use-config)
    │
    └── *.sh                  ← Category scripts
```

## Usage Examples

### From Root (Recommended)
```bash
# Config mode
./unix.sh --use-config

# Interactive mode
./unix.sh

# Specific categories
./unix.sh cli langs editors

# Config with overrides
./unix.sh --use-config -e devops
./unix.sh --use-config -o cli

# Dry run
./unix.sh --dry-run --use-config

# List categories
./unix.sh --list

# Help
./unix.sh --help
```

### From sh/ Directory
```bash
cd sh/

# All the same options work
./install.sh --use-config
./install.sh cli langs
./install.sh --help
```

## Options Summary

```
-h, --help           Show help message
-l, --list          List all available categories
-c, --use-config    Use config.sh for decisions
-a, --all           Install all categories
-e, --exclude       Exclude categories
-o, --only          Only specified categories (config mode)
-d, --dry-run       Preview installation
-i, --interactive   Force interactive mode
-y, --yes           Non-interactive mode
```

## Migration from Old System

### If you were using `install-with-config.sh`:
```bash
# Old way
./sh/install-with-config.sh

# New way (both work)
./unix.sh --use-config
./sh/install.sh --use-config
```

### If you were using `install.sh`:
```bash
# Old way
./sh/install.sh cli langs

# New way (both work)
./unix.sh cli langs
./sh/install.sh cli langs
```

## Benefits

1. **Single Source of Truth**: One installer script, three modes
2. **Clear Entry Point**: `unix.sh` at root makes it obvious
3. **Backward Compatible**: Old scripts still work (deprecated but functional)
4. **Simpler**: Less confusion about which script to use
5. **Flexible**: All modes in one place with clean flag interface

## Technical Details

### unix.sh
- Simple wrapper script
- Detects repository root
- Passes all arguments to `sh/install.sh`
- Uses `exec` for clean process replacement

### sh/install.sh
- Unified implementation
- Parses `--use-config` flag to enable config mode
- Loads config.sh when needed
- Handles interactive prompts or CLI arguments
- Applies overrides (--exclude, --only)

### sh/install-with-config.sh
- Marked as DEPRECATED
- Prints warning message
- Redirects to `install.sh --use-config`
- Kept for backward compatibility only

## Files Changed

### Modified:
- `sh/install.sh` - Completely rewritten as unified installer
- `sh/install-with-config.sh` - Converted to deprecation wrapper
- `README.md` - Updated with new entry point info
- `sh/README.md` - Updated examples and architecture

### Created:
- `unix.sh` - New root-level entry point
- `UNIFIED_ENTRY_POINT.md` - This summary document

## Testing

All modes tested and working:

```bash
# Config mode
✓ ./unix.sh --use-config
✓ ./unix.sh --use-config -e devops
✓ ./unix.sh --use-config -o cli

# CLI arguments
✓ ./unix.sh cli langs
✓ ./unix.sh --all
✓ ./unix.sh --all -e docker

# Interactive mode
✓ ./unix.sh
✓ ./unix.sh --list

# Dry run
✓ ./unix.sh --dry-run --use-config
✓ ./unix.sh --dry-run cli

# Help
✓ ./unix.sh --help
```

## Summary

The installation system now has:
- ✅ Single unified entry point (`unix.sh`)
- ✅ One installer handling all modes (`sh/install.sh`)
- ✅ Clear, consistent interface
- ✅ Backward compatibility maintained
- ✅ Simpler for users to understand and use

**Bottom line**: Use `./unix.sh` for everything! 🚀
