{
  # Main system description
  description = "Darwin (macOS) system flake for jessup";

  # External dependencies and inputs
  inputs = {
    # Core Nix packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Flake-parts framework
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Darwin system configuration framework
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User environment management framework
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Integration for managing Homebrew packages with Nix
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Homebrew package repositories
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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Lix project module
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nixvim module
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SOPS-nix
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-secrets = {
      url = "github:djessup/nix-secrets";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" "x86_64-darwin" ];
      
      imports = [
        # Hosts configuration 
        ./hosts
        
        # Overlays module
        ./overlays
      ];
      
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here
        # Set default formatter for nix fmt
        formatter = pkgs.nixpkgs-fmt;
      };
    };
}
