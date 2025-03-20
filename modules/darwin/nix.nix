{
  pkgs,
  lib,
  config,
  inputs,
  user,
  ...
}: {
  # Configure Nix package manager
  nix = {
    # Inject access tokens from SOPS if available
    extraOptions = lib.mkIf (config ? sops.secrets.nixAccessTokens) ''
      !include ${config.sops.secrets.nixAccessTokens.path}
    '';

    settings = {
      # Enable flakes and new nix command
      experimental-features = [ "nix-command" "flakes" ];
      
      # Trusted users
      trusted-users = [ "@admin" "${user}" ];
      
      # Add cachix binary cache
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      
      # Optimize storage
      auto-optimise-store = true;
      
      # Use sandbox for build environment isolation
      sandbox = true;
      
      # Allow more cores for builds
      max-jobs = 8;
      cores = 0;
    };

    # Store optimization settings
    optimise = {
      automatic = true;
    };
    
    # Garbage collection settings
    gc = {
      automatic = true;
      interval = { Hour = 3; Minute = 0; };
      options = "--delete-older-than 1w";
    };
  };
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Program settings
  programs = {
    bash.completion.enable = true;
    man.enable = true;
    nix-index.enable = true;
    zsh.enable = true;
  };
} 