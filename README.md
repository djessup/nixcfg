# Nix-Darwin Configuration

This is a modular nix-darwin configuration for macOS systems. It uses flake-parts to organize the configuration into logical modules.

## Structure

```
.
├── flake.nix                    # Main entry point
├── hosts/                       # Host-specific configurations
│   ├── default.nix              # Imports all hosts
│   ├── jessup-mbp/              # Configuration for specific hosts
│   │   ├── default.nix          # Host-specific Nix settings
│   │   └── configuration.nix    # Host-specific configuration
├── modules/                     # Reusable modules
│   ├── darwin/                  # macOS-specific modules
│   │   ├── default.nix          # Imports all Darwin modules
│   │   ├── environment.nix      # Environment variables and paths
│   │   ├── homebrew.nix         # Homebrew package management
│   │   ├── network.nix          # Network settings
│   │   ├── nix.nix              # Nix package manager settings
│   │   ├── security.nix         # Security settings
│   │   ├── system.nix           # System settings and defaults
│   │   └── dock/                # Dock configuration module
│   │       └── default.nix      # Dock management
│   ├── home/                    # User environment modules
│   │   ├── default.nix          # Home-manager configuration
│   │   ├── extraConfig.zsh      # Additional ZSH configuration
│   │   ├── git.nix              # Git configuration
│   │   ├── neovim/              # Neovim configuration (imports legacy config)
│   │   │   └── default.nix      # Neovim configuration
│   │   ├── programs.nix         # Installed programs
│   │   └── shell.nix            # Shell configuration
│   └── shared/                  # Shared resources
│       └── inputrc              # Readline configuration
├── lib/                         # Helper functions
│   └── default.nix              # Utility functions
└── overlays/                    # Package overlays
    └── default.nix              # Custom overlays
```

## Usage

To build and activate the configuration:

```bash
darwin-rebuild switch --flake .#jessup-mbp
```

To update all inputs:

```bash
nix flake update
```

## Adding New Hosts

1. Create a new directory under `hosts/` with your hostname
2. Copy and modify the configuration files from an existing host
3. Add the new host to `hosts/default.nix`

## Customization

- **System Settings**: Edit `modules/darwin/system.nix`
- **User Packages**: Edit `modules/home/programs.nix`
- **Homebrew Apps**: Edit `modules/darwin/homebrew.nix`
- **Shell Config**: Edit `modules/home/shell.nix` and `modules/home/extraConfig.zsh`
- **Dock Layout**: Edit the dock section in your host configuration

## Features

- Modular and maintainable configuration
- Full Homebrew integration
- Home-manager for user environments
- Custom dock management
- Security settings including TouchID for sudo

## Migration Notes

This configuration currently still imports some legacy settings from the old structure. These should be gradually migrated to the new modular structure:

1. **Neovim Configuration**: Currently imports from `user/settings/neovim`. This should be migrated to a proper modular setup in `modules/home/neovim/`.

2. **Legacy Imports**: The host configuration still imports from the old `darwin` and `user` directories. These should be migrated to appropriate modules and then the imports removed.

Once all settings have been migrated to the new structure, the legacy imports can be removed for a cleaner configuration. 