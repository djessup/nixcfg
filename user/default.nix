# User-specific configuration using home-manager
{
  config,
  inputs,
  pkgs,
  lib,
  home-manager,
  nixvim,
  user,
  ...
}:
{
  # Import dock configuration
  imports = [
    ./dock # Dock configuration for macOS
  ];

  # System-level user definition
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh; # Set zsh as the default shell
  };
  
  # Home-manager configuration
  home-manager = {
    useGlobalPkgs = true;      # Use packages from system nixpkgs
    useUserPackages = true;    # Install packages to the user profile
    backupFileExtension = "before-hm"; # Suffix for backed up files
    verbose = true;            # Enable verbose output during operations
    
    # User-specific home-manager settings
    users.${user} = { pkgs, config, lib, ... }: {
      # Import modular configuration files
      imports = [
        inputs.sops-nix.homeManagerModules.sops
        nixvim.homeManagerModules.nixvim
        ./settings/programs.nix # Program-specific configurations
        ./settings/zsh.nix      # ZSH shell configuration
        ./settings/neovim   # Neovim configuration
      ];
      
      # Home configuration
      home = {
        # Install packages defined in packages.nix
        packages = (import ./settings/packages.nix { inherit pkgs; }).packages;

        # Dotfiles
        file.".inputrc".source = ./settings/inputrc;
        
        # Required by home-manager, do not change
        stateVersion = "24.11";
        
      };
    };
    
    # Pass special arguments to home-manager modules
    extraSpecialArgs = {
      inherit inputs;
      inherit user;
    };
  };

  # Dock configuration using custom module
  local.dock = {
    enable = true;
    entries = [
      # Terminal applications
      { path = "${pkgs.iterm2}/Applications/iTerm2.app/"; }
      { path = "${pkgs.warp-terminal}/Applications/Warp.app/"; }
      
      # Development tools
      { path = "${pkgs.code-cursor}/Applications/Cursor.app/"; }
      
      # Communication applications
      { path = "/Applications/Microsoft Teams.app/"; }
      { path = "/Applications/Slack.app/"; }
      { path = "/Applications/Microsoft Outlook.app/"; }
      
      # Productivity applications
      { path = "/Applications/Notes.app/"; }
      { path = "/Applications/Microsoft Edge.app/"; }
      { path = "/System/Applications/System Settings.app/"; }
      { path = "/Applications/Github Desktop.app/"; }
      { path = "/System/Applications/Podcasts.app/"; }
      { path = "/Applications/ChatGPT.app/"; }

      # Development IDEs
      { path = "${pkgs.jetbrains.idea-ultimate}/Applications/IntelliJ IDEA.app/"; }
      { path = "${pkgs.jetbrains.clion}/Applications/CLion.app/"; }
      { path = "${pkgs.jetbrains.rust-rover}/Applications/RustRover.app/"; }
      
      # Folders
      {
        path = "/Applications";
        section = "others";
        options = "--sort name --view grid --display folder";
      }
      {
        path = "${config.users.users.${user}.home}/Downloads";
        section = "others";
        options = "--sort name --view fan --display stack";
      }
    ];
  };
}
