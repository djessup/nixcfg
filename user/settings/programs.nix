{ config, pkgs, ... }:
{
  # Add ~/.local/bin to PATH for tools like uv, rye, etc.
  home.sessionPath = [ "$HOME/.local/bin" ];

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
      enableBashIntegration = true;
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

    # Let home Manager install and manage itself.
    home-manager.enable = true;
  };
}
