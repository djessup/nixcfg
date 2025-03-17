{
  description = "Work MacBook Pro (Darwin) system flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Nix Darwin
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Nix Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Nix Homebrew
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarative Homebrew taps
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
    # Nix User Repository
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Lix 
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-1.tar.gz";
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
      ...
    }:
    {
      darwinConfigurations =
        let
          user = "jessup";
        in
        {
          jessup-mbp = darwin.lib.darwinSystem {
            specialArgs = { inherit inputs user; };
            modules = [
              ./darwin
              # System-level Home Manager config
              home-manager.darwinModules.home-manager
              ./user
              # System-level Homebrew config
              nix-homebrew.darwinModules.nix-homebrew
              {
               
              }
              lix-module.nixosModules.default
            ];
          };
        };
    };

}
