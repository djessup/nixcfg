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

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  # Build darwin flake using:
  # $ darwin-rebuild build --flake .#jessup
  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew, ... }: 
    let nixpkgsConfig = { config.allowUnfree = true; }; in {
      darwinConfigurations = 
      let inherit (inputs.nix-darwin.lib) darwinSystem; in {
        "jessup" = darwinSystem {
          specialArgs = { inherit inputs; };
          modules = [ 
            ./configuration.nix 
            # System-level Home Manager config
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "before-hm";
                verbose = true;
                users."jessup" = import ./home.nix;
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
                user = "jessup";
                # Automatically migrate existing Homebrew installations
                autoMigrate = true;
              };
            }
          ];
        };
      };
    };

}