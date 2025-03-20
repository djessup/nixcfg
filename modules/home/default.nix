{
  pkgs,
  lib,
  config,
  user,
  inputs,
  ...
}: {
  # Define system user
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };
  
  # Configure home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "before-hm";
    verbose = true;
    extraSpecialArgs = { inherit user inputs; };
    
    users.${user} = { pkgs, ... }: {
      imports = [
        # Import individual home-manager modules
        ./shell.nix
        ./git.nix
        ./programs.nix
        ./neovim
        inputs.nixvim.homeManagerModules.nixvim
        inputs.sops-nix.homeManagerModules.sops
      ];
      
      # Let home-manager manage itself
      programs.home-manager.enable = true;
      
      # Common settings
      home = {
        username = user;
        homeDirectory = "/Users/${user}";
        stateVersion = "24.11";
        
        # Add a inputrc file
        file.".inputrc".source = ../shared/inputrc;
      };
    };
  };
} 