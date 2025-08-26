# System-wide configuration for Darwin (macOS)
{
  config,
  inputs,
  user,
  ...
}: {

  # Nix package manager configuration
  nix = {
    # Enable Linux builder for cross-compilation
    # May need to disable this config and/or run `nix run nixpkgs#darwin.linux-builder`
    # first, if build fails, or after rebuild to setup ssh keys
    linux-builder = {
      enable = true;
      ephemeral = true;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 40 * 1024; # 40 GB
            memorySize = 8 * 1024; # 8 GB
          };
          cores = 6;
        };
      };
    };

    # Inject access tokens from SOPS
    extraOptions = ''
      !include ${config.sops.secrets.nixAccessTokens.path}
    '';

    # Enable flakes and nix-command features
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [ "@admin" "${user}" ]; # Allow specified users to perform privileged Nix operations

      # Configure binary caches for faster downloads
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      # Optimize downloads with a larger number of connections
      max-jobs = 8;
      cores = 0;
    };

    # Store optimization settings
    optimise = {
      automatic = true; # Enable automatic optimization of the Nix store
    };

    # Garbage collection settings
    gc = {
      automatic = true;                     # Enable automatic garbage collection
      interval = { Hour = 2; Minute = 0; }; # Schedule GC for 2:00 AM every day
      options = "--delete-older-than 1w";   # Remove items older than 1 week
    };
  };

  # Platform and package configuration
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config = {
      allowUnfree = true;
    };

    # Package overlays
    overlays = [
      (final: prev: {
        pkgsStable = import inputs.nixpkgsStable {
          inherit (final) system;
          config = prev.config or {};
        };
      })
    ];

  };

  # App configs
  programs = {
    zsh.enable = true;              # ZSH as default shell
    bash.completion.enable = true;  # Enable bash completion for bash shell
    man.enable = true;              # Enable man pages for documentation
    nix-index.enable = true;        # Enable nix-index for command-not-found functionality
    gnupg.agent.enable = true;      # Enable GPG agent for cryptographic operations
    # tmux settings
    tmux = {
      enable = true;
      enableMouse = true; # Enable mouse support in tmux
      enableFzf = true; # Enable fzf integration in tmux
      enableVim = true; # Enable vim style keybindings in tmux
      enableSensible = true; # Enable sensible defaults for tmux
    };
  };

  # Additional system program configurations

  # Import modular configuration files
  imports = [
    ./settings/secrets.nix       # Secret management w/ SOPS
    ./settings/system.nix        # System settings for macOS
    ./settings/environment.nix   # Environment variables and paths
    ./settings/security.nix      # Security-related settings
    ./settings/network.nix       # Network configuration
    ./settings/homebrew.nix      # Homebrew package management
    ./settings/devenv.nix        # Devenv dev environment manager
    ./settings/github-runners.nix # GitHub self-hosted runners
  ];
}
