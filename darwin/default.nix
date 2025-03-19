# System-wide configuration for Darwin (macOS)
{
  config,
  pkgs,
  inputs,
  home-manager,
  user,
  sops-nix,
  ...
}:
{
  # Sops configuration
  sops = {
    defaultSopsFile = ../nix-secrets/secrets.yaml;
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
       extraOptions = ''
        !include ${config.sops.secrets.nixAccessTokens.path}
      '';
    # Enable flakes and nix-command features
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [ "root" "${user}" ]; # Allow specified users to perform privileged Nix operations

      # extra-access-tokens = [
      #   # "github.com=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"
      #   "!include ${config.sops.secrets.nixAccessTokens.path}"
      # ];

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
      automatic = true; # Enable automatic garbage collection
      interval = { Hour = 2; }; # Schedule GC for 2:00 AM every day
      options = "--delete-older-than 14d"; # Remove items older than 14 days
    };
  };

  # Platform and package configuration
  nixpkgs = {
    hostPlatform = "aarch64-darwin"; # Target Apple Silicon architecture
    config = {
      allowUnfree = true; # Allow installation of non-free/proprietary software packages
      # Allow installation of NUR packages
      packageOverrides = pkgs: {
        nur = import (builtins.fetchTarball {
          # Get the revision by choosing a version from https://github.com/nix-community/NUR/commits/main
          url = "https://github.com/nix-community/NUR/archive/3a6a6f4da737da41e27922ce2cfacf68a109ebce.tar.gz";
          # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
          sha256 = "04387gzgl8y555b3lkz9aiw9xsldfg4zmzp930m62qw8zbrvrshd";
        }) {
          inherit pkgs;
        };
      };
    };
  };

  # nur = import (builtins.fetchTarball {
  #   url = "https://github.com/nix-community/NUR/archive/f5ada523d9f9f295d15a601997f2ec41e0b85028.tar.gz";
  #   sha256 = "0pf4rr0pf6g8rbk6wwh09sipp2bfjm5qn07yi63gr2g3xfyg78lq";
  # }) {
  #   inherit pkgs;
  # };


  # Shell configuration
  programs.zsh = {
    enable = true;
    # Commented options can be enabled if needed:
    # enableCompletion = true;
    # enableBashCompletion = true;
    # enableLsColors = true;
    # enableFzfCompletion = true;
    # enableFzfGit = true;
    # enableFzfHistory = true;
  };

  # Additional system program configurations
  programs.bash.completion.enable = true; # Enable bash completion for bash shell
  programs.man.enable = true; # Enable man pages for documentation
  programs.nix-index.enable = true; # Enable nix-index for command-not-found functionality

  # Import modular configuration files
  imports = [
    ./settings/system.nix      # System settings for macOS
    ./settings/environment.nix # Environment variables and paths
    ./settings/security.nix    # Security-related settings
    ./settings/network.nix     # Network configuration
    ./settings/homebrew.nix    # Homebrew package management
  ];
}
