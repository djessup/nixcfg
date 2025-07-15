# Nix Cleanup Script

A comprehensive Nix store cleanup tool designed for nix-darwin systems that safely removes old generations, performs garbage collection, and optimizes the store for maximum space recovery.

## Features

### Core Functionality
- **User-level cleanup**: Clean user profiles with `nix-collect-garbage`
- **System-level cleanup**: Clean nix-darwin system profile generations (requires sudo)
- **Safe time thresholds**: Default 1-day threshold protects recent generations
- **Store optimization**: Automatic deduplication of identical files

### User Experience
- **Clear usage instructions**: Built-in help with `--help` flag
- **Before/after statistics**: Shows disk usage and space reclaimed
- **Colored output**: User-friendly progress indicators and status messages
- **Dry-run mode**: Preview changes with `--dry-run` before executing

### Safety & Options
- **Flexible thresholds**: Custom time thresholds (1h, 6h, 1d, 7d, 30d, 1m)
- **Generation limits**: Keep specific number of recent generations
- **Confirmation prompts**: Safety prompts for destructive operations
- **Verbose mode**: Detailed information about operations

## Installation

The script is automatically installed as part of your nix-darwin configuration and available system-wide as `nix-cleanup`.

## Usage

### Basic Usage
```bash
# Safe user-only cleanup (default)
nix-cleanup

# Full cleanup including system profiles
nix-cleanup --full

# Preview what would be cleaned
nix-cleanup --dry-run --full
```

### Advanced Options
```bash
# Custom time threshold
nix-cleanup -t 7d --verbose

# Keep specific number of generations
nix-cleanup -k 5 --user-only

# Show largest store paths before cleanup
nix-cleanup --largest

# Skip confirmation prompts
nix-cleanup --full --yes
```

### Command Line Options

| Option | Description |
|--------|-------------|
| `-u, --user-only` | Clean only user profiles (no sudo required) |
| `-f, --full` | Full cleanup including system profiles (requires sudo) |
| `-t, --threshold TIME` | Time threshold for cleanup (default: 1d) |
| `-k, --keep NUM` | Keep NUM most recent generations regardless of time |
| `-n, --dry-run` | Show what would be cleaned without doing it |
| `-y, --yes` | Skip confirmation prompts |
| `-v, --verbose` | Show detailed information about operations |
| `-l, --largest` | Show largest store paths before cleanup |
| `-h, --help` | Show help message |
| `--version` | Show version information |

## Safety Notes

- **Default 1-day threshold** protects recent generations from accidental removal
- **System cleanup requires sudo** and affects nix-darwin rollback capability
- **Always use --dry-run first** to preview changes before executing
- **Automatic store optimization** is already enabled in your nix-darwin configuration

## Integration with Existing Aliases

The script integrates with your existing shell aliases:

```bash
# Updated alias uses the comprehensive script
nix-gc          # Equivalent to: nix-cleanup --user-only
```

## Examples

### Quick Daily Cleanup
```bash
nix-cleanup
# Equivalent to: nix-cleanup --user-only --threshold 1d
```

### Weekly Deep Clean
```bash
nix-cleanup --full --threshold 7d --verbose
# Shorthand: nix-cleanup -f -t 7d -v
```

### Conservative Cleanup (Keep More Generations)
```bash
nix-cleanup --keep 10 --user-only
# Shorthand: nix-cleanup -k 10 -u
```

### Space Analysis
```bash
nix-cleanup --largest --dry-run
# Shorthand: nix-cleanup -l -n
```

## Technical Details

The script performs cleanup in this optimal sequence:

1. **Clean user profiles** - Remove old user environment generations
2. **Clean system profiles** - Remove old nix-darwin generations (if --full)
3. **Final garbage collection** - Remove newly unreachable store paths
4. **Store optimization** - Deduplicate identical files using hard links

This sequence maximizes space recovery by ensuring that removing generations first makes more store paths eligible for garbage collection.
