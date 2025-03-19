{ config, pkgs, ... }:
{

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

    dircolors.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd cd"
      ];
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    bat = {
      enable = true;
      config.theme = "TwoDark";
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    eza.enable = true;

    git = {
      enable = true;
      lfs.enable = true;
      userName = "David Jessup";
      userEmail = "jessup@adobe.com";
      extraConfig = {
        init.defaultBranch = "master";
        credential."https://git.cloudmanager.adobe.com".provider = "generic";
      };
    };

    # Neovim
    nixvim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      luaLoader.enable = true;
    };

    # Let home Manager install and manage itself.
    home-manager.enable = true;
  };
}