# System-wide configuration for Darwin (macOS)
{
  config,
  pkgs,
  inputs,
  home-manager,
  user,
  ...
}:
{
  # Nix package manager configuration
  nix = {
    # Enable flakes and nix-command features
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [ "root" "${user}" ]; # Allow specified users to perform privileged Nix operations
    };
    
    # Store optimization settings
    optimise = {
      automatic = true; # Enable automatic optimization of the Nix store
    };
    
    # Garbage collection settings
    gc = {
      automatic = true; # Enable automatic garbage collection
      interval = { Weekday = 0; Hour = 2; Minute = 0; }; # Schedule GC for Sunday at 2:00 AM
      options = "--delete-older-than 30d"; # Remove items older than 30 days
    };
  };

  # Platform and package configuration
  nixpkgs.hostPlatform = "aarch64-darwin"; # Target Apple Silicon architecture
  nixpkgs.config.allowUnfree = true; # Allow installation of non-free/proprietary software packages

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
