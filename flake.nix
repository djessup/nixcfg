{
  # Main system description
  description = "Work MacBook Pro (Darwin) system flake";

  # External dependencies and inputs
  inputs = {
    # Core Nix packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Darwin system configuration framework
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

    # Homebrew package repositories (flake = false means these are not Nix flakes)
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    # Nix User Repository for community packages
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs as defined above
    };

    # Lix project module
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs as defined above
    };

    # Nixvim module
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs as defined above
    };

    # SOPS-nix
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Build darwin flake using:
  # $ darwin-rebuild build --flake .#jessup
  outputs =
    inputs@{
      self,
      darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
      lix-module,
      nixvim,
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
          # Configuration for jessup's MacBook Pro
          jessup-mbp = darwin.lib.darwinSystem {
            # Pass special arguments to all modules
            specialArgs = { inherit inputs user; };

            # Include all necessary configuration modules
            modules = [
              ./darwin                            # System-wide Darwin settings
              ./user                              # User-specific settings
              home-manager.darwinModules.home-manager  # User environment management
              nix-homebrew.darwinModules.nix-homebrew  # Homebrew integration
              lix-module.nixosModules.default     # Lix module configuration
              sops-nix.darwinModules.sops
            ];
          };
        };
    };
}
