# install

Modern Unix-based installation system with unified entry point.

## Quick Start

```bash
# From repository root - use unix.sh as entry point
./unix.sh                    # Interactive mode
./unix.sh --use-config       # Config-based mode
./unix.sh cli langs          # Install specific categories
./unix.sh --help             # Show all options
```

## Three Installation Modes

1. **Config Mode** (`--use-config`) - Uses `config.sh` for all decisions
2. **Interactive Mode** (default) - Prompts for each tool
3. **CLI Arguments Mode** - Install specific categories from command line

## Entry Points

- **`unix.sh`** (root level) - Main entry point, delegates to sh/install.sh
- **`sh/install.sh`** - Unified installer handling all three modes

See [sh/README.md](sh/README.md) for detailed documentation.

---

**Note**: All scripts are now POSIX-compliant bash and work on any Unix-like system.
TODO: posix compliant? config.zsh?
TODO: windows support?

