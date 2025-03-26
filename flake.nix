{
  # Main system description
  description = "Work MacBook Pro (Darwin) system flake";

  # External dependencies and inputs
  inputs = {
    # Core Nix packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Darwin (macOS) system configuration framework
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs as defined above
    };
    # User environment management framework
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs as defined above
    };
    # Integration for managing Homebrew packages with Nix
    nix-homebrew = {
       url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs as defined above
    };
    # Nix User Repository for community packages
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs as defined above
    };
    # Nixvim module
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs as defined above
    };
    # SOPS-nix secrets module
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Flox dev environment manager
    flox = {
      url = "github:flox/flox/v1.3.16";
    };

    # Private secrets repo
    nix-secrets = {
      url = "github:djessup/nix-secrets";
      flake = false;
    };
  };

  # Build darwin flake using:
  # $ darwin-rebuild build --flake .#jessup-m3
  outputs =
    inputs@{
      self,
      darwin,
      home-manager,
      nix-homebrew,
      sops-nix,
      ...
    }:
    {
      # System configurations
      darwinConfigurations =
        let
          # Define the username once for reuse
          user = "jessup";
        in
        {
          # MacBook Pro configuration
          jessup-m3 = darwin.lib.darwinSystem {
            system = "aarch64-darwin"; # Apple Silicon (e.g. M3 Max)
            # Forward arguments to modules
            specialArgs = { inherit inputs user; };
            # Include configuration modules
            modules = [
              ./darwin                                  # System-wide Darwin settings
              ./user                                    # User-specific settings
              home-manager.darwinModules.home-manager   # User home environment management
              nix-homebrew.darwinModules.nix-homebrew   # Homebrew integration
              sops-nix.darwinModules.sops               # Secrets module (SOPS)
            ];
          };
        };
    };
}
