{
  inputs,
  lib,
  ...
}: {
  flake.darwinConfigurations = {
    jessup-mbp = let
      user = "jessup";
      system = "aarch64-darwin";
    in inputs.darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit inputs user; };
      
      modules = [
        # Import all our custom modules
        ../../modules/darwin
        ../../modules/home
        
        # External modules
        inputs.home-manager.darwinModules.home-manager
        inputs.nix-homebrew.darwinModules.nix-homebrew
        inputs.lix-module.nixosModules.default
        inputs.sops-nix.darwinModules.sops
        
        # Host-specific configuration
        ./configuration.nix
      ];
    };
  };
} 