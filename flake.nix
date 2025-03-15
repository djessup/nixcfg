{
  description = "Work MacBook Pro (Darwin) system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Build darwin flake using:
  # $ darwin-rebuild build --flake .#jessup
  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew, ... }: 
    {
      darwinConfigurations = 
      let 
        user = "jessup";
        inherit (inputs.nix-darwin.lib) darwinSystem; 
        in {
        "${user}" = darwinSystem {
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
                user = "${user}";
                # Automatically migrate existing Homebrew installations
                autoMigrate = true;
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