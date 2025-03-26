# System-wide configuration for Darwin (macOS)
{
  config,
  inputs,
  user,
  ...
}:
let
  # Path to the secrets repository
  secretspath = builtins.toString inputs.nix-secrets;
in
{
  # SOPS configuration
  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    age = {
      keyFile = "${config.users.users.${user}.home}/.config/sops/age/keys.txt";
    };
    secrets.nixAccessTokens = {
      mode = "0400";
      owner = config.users.users.${user}.name;
    };
  };

  # Nix package manager configuration
  nix = {
    # Inject access tokens from SOPS
    extraOptions = ''
      !include ${config.sops.secrets.nixAccessTokens.path}
    '';

    # linux-builder.enable = true;

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
      interval = { Hour = 3; Minute = 0; }; # Schedule GC for 3:00 AM every day
      options = "--delete-older-than 1w";   # Remove items older than 1 week
    };
  };

  # Platform and package configuration
  nixpkgs = {
    hostPlatform = "aarch64-darwin"; # Target Apple Silicon architecture
    config = {
      allowUnfree = true;            # Allow installation of non-free/proprietary software packages
    };
  };

  # Shell configuration
  programs.zsh = {
    enable = true;
  };

  # Additional system program configurations
  programs.bash.completion.enable = true; # Enable bash completion for bash shell
  programs.man.enable = true;             # Enable man pages for documentation
  programs.nix-index.enable = true;       # Enable nix-index for command-not-found functionality

  # Import modular configuration files
  imports = [
    ./settings/system.nix      # System settings for macOS
    ./settings/environment.nix # Environment variables and paths
    ./settings/security.nix    # Security-related settings
    ./settings/network.nix     # Network configuration
    ./settings/homebrew.nix    # Homebrew package management
    ./settings/flox.nix        # Flox dev environment manager
  ];
}
