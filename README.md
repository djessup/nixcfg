# macOS Development Environment (nix-darwin)

A declarative macOS development environment managed through nix-darwin and home-manager. 

This configuration provides a consistent, reproducible development setup with customized applications, 
shell environment, and development tools.

## 🚀 Features

- **Declarative System Management**: Everything configured through Nix expressions
- **Flake-based Configuration**: Reproducible builds with pinned dependencies
- **Comprehensive Development Environment**: 240+ packages and tools
- **Advanced Neovim IDE**: Full-featured editor with LSP, completion, and debugging
- **Optimized Shell Experience**: Zsh with oh-my-zsh, aliases, and productivity tools
- **macOS Integration**: Dock management, system preferences, and native app integration
- **Homebrew Integration**: Seamless management of casks and Mac App Store apps
- **SSH Key Management**: Apple Keychain integration with automatic key loading
- **Secrets Management**: SOPS integration for encrypted configuration
- **Development Environment Managers**: Support for devenv and mise

## 📋 Prerequisites

- macOS (on Apple Silicon)
- [Nix Package Manager](https://nixos.org/download.html) with flakes enabled
- [nix-darwin](https://github.com/LnL7/nix-darwin) installed
- **SOPS age private key** (available in Bitwarden vault)
- Access to the private `github:djessup/nix-secrets` repository

### Quick Nix Installation

```bash
# Install Nix with flakes support
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Install nix-darwin
nix run nix-darwin -- switch --flake github:djessup/nix-darwin
```

## 🛠️ Installation

### 1. **Setup SOPS Secrets Management**

Before building the configuration, you need to set up the age encryption key for secrets management:

```bash
# Create the SOPS directory
mkdir -p ~/.config/sops/age

# Retrieve the age private key from Bitwarden vault
# Look for "nix-darwin age private key" in your Bitwarden vault
# Copy the key content to the keys.txt file
nano ~/.config/sops/age/keys.txt

# Set proper permissions (critical for security)
chmod 600 ~/.config/sops/age/keys.txt
```

**Key format** (3 lines):
```
# created: 2025-03-19T10:10:27+11:00
# public key: age1frpdm7hsq3r23cz3u8ua6p289pcxd05lwjhw0ejs4dk6a9ez337sx7tz7k
AGE-SECRET-KEY-[PRIVATE_KEY_DATA]
```

### 2. **Clone this repository**:
```bash
git clone <repository-url> /etc/nix-darwin
cd /etc/nix-darwin
```

### 3. **Verify secrets access**:
```bash
# Test that you can access the secrets (optional but recommended)
nix eval --json .#darwinConfigurations.jessup-m3.config.sops.secrets
```

### 4. **Apply the configuration**:
```bash
darwin-rebuild switch --flake .#jessup-m3
```

### 5. **Restart your terminal** to load the new shell configuration.

## 📁 Project Structure

```
nix-darwin/
├── flake.nix                 # Main flake configuration and inputs
├── flake.lock               # Pinned dependency versions
├── darwin/                  # System-wide configurations
│   ├── default.nix         # Main darwin configuration
│   └── settings/           # System settings modules
│       ├── devenv.nix      # Devenv development environment
│       ├── environment.nix # Environment variables and paths
│       ├── homebrew.nix    # Homebrew package management
│       ├── network.nix     # Network and hostname settings
│       ├── security.nix    # Security and authentication
│       └── system.nix      # macOS system preferences
└── user/                   # User-specific configurations
    ├── default.nix         # Home-manager setup
    ├── dock/               # Dock management utilities
    └── settings/           # User configuration modules
        ├── dock.nix        # Dock application layout
        ├── neovim/         # Neovim IDE configuration
        ├── packages.nix    # User packages and tools
        ├── programs.nix    # Program configurations
        ├── ssh.nix         # SSH and keychain setup
        └── zsh.nix         # Shell configuration
    └── settings/           # User application settings
        ├── neovim/         # Comprehensive Neovim configuration
        ├── packages.nix    # User package definitions
        ├── programs.nix    # Program-specific configurations
        └── zsh.nix         # Zsh shell configuration
```

## 🔧 Configuration Overview

### System Configuration
- **Package Management**: Nix packages + Homebrew integration
- **System Preferences**: Dark mode, Finder settings, dock behavior
- **Security**: TouchID/WatchID sudo authentication
- **Development Tools**: Build tools, compilers, and runtimes

### Development Environment
- **Languages**: Python, Node.js, Rust, Go, Java, C/C++, embedded development
- **Databases**: SQLite tools and utilities
- **Cloud Tools**: AWS CLI, Kubernetes, Terraform, Docker
- **AI Tools**: Ollama, various LLM utilities, AI-assisted coding tools
- **Development Environments**: devenv, mise, direnv for project isolation
- **Version Control**: Git with advanced tooling and integrations

### Neovim IDE Features
- **Language Servers**: Go, Python, TypeScript, Lua, Nix, and more
- **Code Completion**: nvim-cmp with multiple sources
- **Debugging**: DAP support for multiple languages
- **Git Integration**: Lazygit, gitsigns, gitblame
- **File Navigation**: Oil.nvim, Telescope fuzzy finder
- **UI Enhancements**: Lualine status line, icons, themes

### Shell Environment
- **Zsh Configuration**: oh-my-zsh with productivity plugins
- **Aliases**: Git shortcuts, directory navigation, development tools
- **History**: Enhanced history management and search
- **Completions**: Advanced tab completion for various tools

## 🚀 Usage

### Daily Commands

```bash
# Update and rebuild the configuration
nixup

# Build configuration without switching
nixbuild

# Rebuild configuration (verbose)
nixswitch

# Update flake inputs
nixfluff

# Build configuration for testing
nombuild
```

### Package Management

```bash
# Search for packages
nix search nixpkgs <package-name>

# Add packages by editing user/settings/packages.nix
# Then rebuild with: nixswitch
```

### Homebrew Integration

Homebrew packages are managed declaratively in `darwin/settings/homebrew.nix`:
- **Brews**: Command-line tools not available in nixpkgs
- **Casks**: GUI applications
- **Mac App Store**: Apps via `mas`

## 🔄 Updating

### Update Dependencies
```bash
cd /etc/nix-darwin
nix flake update
darwin-rebuild switch --flake .#jessup-m3
```

### Update Specific Input
```bash
nix flake lock --update-input nixpkgs
```

## 🛠️ Customization

### Adding New Packages
1. Edit `user/settings/packages.nix`
2. Add package to the appropriate section
3. Run `nixswitch` to rebuild

### Modifying System Settings
1. Edit files in `darwin/settings/`
2. Run `nixswitch` to apply changes

### Neovim Customization
1. Add plugins in `user/settings/neovim/plugins/`
2. Modify settings in respective configuration files
3. Rebuild to apply changes

### SSH Configuration
The SSH setup includes automatic Apple Keychain integration:
- SSH keys are automatically loaded from keychain at login
- ScaleFT/Okta Advanced Server Access support
- Modify `user/settings/ssh.nix` to add your SSH key paths

### Secrets Management (SOPS)
This configuration uses SOPS with age encryption for sensitive data:

**Setup for new machine**:
1. Retrieve age private key from Bitwarden vault ("nix-darwin age private key")
2. Save to `~/.config/sops/age/keys.txt` with 600 permissions
3. Ensure access to private `github:djessup/nix-secrets` repository

**Current secrets**:
- `nixAccessTokens`: Nix binary cache access tokens
- Automatically decrypted during system build

**Key management**:
- Public key: `age1frpdm7hsq3r23cz3u8ua6p289pcxd05lwjhw0ejs4dk6a9ez337sx7tz7k`
- Private key backed up in Bitwarden vault
- Used for encrypting/decrypting configuration secrets

## 🔍 Troubleshooting

### Common Issues

**SOPS/Secrets Issues**:
```bash
# Check if age private key exists and has correct permissions
ls -la ~/.config/sops/age/keys.txt
stat -c "%a" ~/.config/sops/age/keys.txt  # Should show 600

# Verify you can decrypt secrets manually
sops -d /nix/store/[hash]-source/secrets.yaml

# Check if you can access the private secrets repository
nix flake show github:djessup/nix-secrets

# Get your current age public key (for verification)
age-keygen -y ~/.config/sops/age/keys.txt
```

**If secrets fail to decrypt**:
1. Ensure the age private key is correctly copied from Bitwarden
2. Verify file permissions are set to 600 (owner read/write only)
3. Check you have access to the private `nix-secrets` repository
4. Confirm the key format matches the expected 3-line structure

**Build Failures**:
```bash
# Check flake syntax
nix flake check

# Verbose rebuild for debugging
darwin-rebuild switch --flake .#jessup-m3 --show-trace -L -vv

# Build without secrets (for testing)
nix build .#darwinConfigurations.jessup-m3.config.system.build.toplevel --show-trace
```

**Package Conflicts**:
- Remove conflicting packages from Homebrew
- Use `nix-env --uninstall` for imperative packages

**Shell Issues**:
- Restart terminal after configuration changes
- Check zsh configuration in `user/settings/zsh.nix`

### Getting Help

1. Check the [nix-darwin documentation](https://daiderd.com/nix-darwin/)
2. Review [home-manager options](https://nix-community.github.io/home-manager/options.html)
3. Search [nixpkgs packages](https://search.nixos.org/packages)
4. For SOPS issues, see [SOPS documentation](https://github.com/mozilla/sops)

**Note**: This configuration requires access to private secrets. Ensure you have:
- The age private key from Bitwarden vault
- Access to the private `nix-secrets` repository

## 🎯 Development Workflow

This configuration supports a modern development workflow:

1. **Project Setup**: Use `direnv` for project-specific environments
2. **Code Editing**: Neovim with full IDE features
3. **Version Control**: Git integration throughout the environment
4. **Testing & Debugging**: DAP support for multiple languages
5. **Deployment**: AWS, Kubernetes, and cloud tools ready

## 🔐 Security Features

- **SOPS Integration**: Encrypted secrets management with age encryption
  - Private age key stored securely in Bitwarden vault
  - Secrets repository: `github:djessup/nix-secrets`
  - Used for Nix access tokens and sensitive configuration
- **SSH Key Management**: Apple Keychain integration with automatic key loading
- **TouchID/WatchID**: Biometric authentication for sudo operations
- **GPG Integration**: Cryptographic operations with pinentry support
- **ScaleFT/Okta Integration**: Enterprise SSH access management

## 📊 Statistics

- **Lines of Code**: ~3,000+ lines of Nix configuration
- **Packages**: 240+ development tools and utilities
- **Neovim Plugins**: 25+ carefully selected plugins
- **System Modules**: Highly modular architecture with 12+ configuration modules
- **Development Languages**: 10+ programming languages supported
- **IDE Support**: Full JetBrains suite, VS Code, Cursor, and Neovim

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the configuration builds successfully
5. Submit a pull request

## 📄 License

This configuration is provided as-is for educational and personal use. Individual packages and tools maintain their respective licenses.

---

**Note**: This configuration is optimized for Apple Silicon Macs. Intel Mac users may need to adjust architecture settings in `flake.nix`.

For questions or issues, please refer to the troubleshooting section or consult the official nix-darwin documentation. 
