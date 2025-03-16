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
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "before-hm";
                  verbose = true;
                  users."${user}" = import ./home;
                  extraSpecialArgs = {
                    inherit inputs;
                    inherit user;
                  };
                };
              }
              # System-level Homebrew config
              nix-homebrew.darwinModules.nix-homebrew
              {
                nix-homebrew = {
                  # Install Homebrew under the default prefix
                  enable = true;

                  # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                  enableRosetta = true;

                  # User owning the Homebrew prefix
                  user = user;

                  # Optional: Declarative tap management
                  # taps = {
                  #   "homebrew/homebrew-core" = homebrew-core;
                  #   "homebrew/homebrew-cask" = homebrew-cask;
                  #   "homebrew/homebrew-bundle" = homebrew-bundle;
                  # };

                  # Optional: Enable fully-declarative tap management
                  # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
                  mutableTaps = true;
                };
              }
            ];
          };
        };
    };

  # Fully declarative dock using the latest from Nix Store
  # local = {
  #   dock.enable = true;
  #   dock.entries = [
  #     { path = "${pkgs.iterm2}/Applications/iTerm.app/"; }
  #     { path = "${pkgs.warp-terminal}/Applications/Warp.app/"; }
  #     { path = "${pkgs.code-cursor}/Applications/Cursor.app/"; }
  #     { path = "/Applications/Microsoft Teams.app/"; }
  #     { path = "/Applications/Slack.app/"; }
  #     { path = "/Applications/Outlook.app/"; }
  #     { path = "/Applications/Microsoft Edge.app/"; }
  #     { path = "/Applications/System Settings.app/"; }
  #     { path = "/Applications/Github Desktop.app/"; }
  #     { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
  #     { path = "/System/Applications/Podcasts.app/"; }
  #     { path = "/Applications/ChatGPT.app/"; }

  #     { path = "${pkgs.jetbrains.idea-ultimate}/Applications/IntelliJ IDEA.app/"; }
  #     { path = "${pkgs.jetbrains.clion}/Applications/CLion.app/"; }
  #     { path = "${pkgs.jetbrains.rust-rover}/Applications/RustRover.app/"; }
  #     {
  #       path = "/Applications";
  #       section = "others";
  #       options = "--sort name --view grid --display folder";
  #     }
  #     # {
  #     #   path = "${config.users.users.${user}.home}/Downloads";
  #     #   section = "others";
  #     #   options = "--sort name --view grid --display stack";
  #     # }
  #   ];
  # };
}
