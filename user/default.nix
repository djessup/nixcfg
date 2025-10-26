# User-specific configuration using home-manager
{
  config,
  inputs,
  pkgs,
  user,
  ...
}:
{

  # System-level user definition
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh; # Set zsh as the default shell
  };

  # Home-manager configuration
  home-manager = {
    useGlobalPkgs = true; # Use packages from system nixpkgs
    useUserPackages = true; # Install packages to the user profile
    backupFileExtension = "before-hm"; # Suffix for backed up files
    verbose = true; # Enable verbose output during operations

    # User-specific home-manager settings
    users.${user} =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        # Import dock configuration
        imports = [
          inputs.sops-nix.homeManagerModules.sops
          inputs.nixvim.homeModules.nixvim
          ./dock # Dock management utility
          ./settings/dock.nix # Dock and uBar user configuration
          ./settings/programs.nix # Program-specific configurations
          ./settings/bash.nix # Bash shell configuration
          ./settings/zsh.nix # ZSH shell configuration
          ./settings/shell-init.nix # Development environment shell initialization
          ./settings/neovim # Neovim configuration
          ./settings/ssh.nix # SSH configuration
          ./settings/git-configs.nix # Conditional Git configurations for different emails
        ];

        # openssh.authorizedKeys = [];

        # Home configuration
        home = {
          # Install packages defined in packages.nix
          packages = (import ./settings/packages.nix { inherit inputs pkgs; }).packages;

          # Dotfiles
          file.".inputrc".source = ./settings/inputrc;

          # Required by home-manager, do not change
          stateVersion = "24.11";

          # Activate system settings immediately after user activation, without requiring a reboot
          activation.activateSystemSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            run \
                /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
          '';
        };
      };

    # Pass special arguments to home-manager modules
    extraSpecialArgs = {
      inherit inputs;
      inherit user;
    };
  };

}
