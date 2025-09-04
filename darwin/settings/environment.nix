{ pkgs, user, ... }:
 let
  # Import custom scripts
  scripts = import ../../scripts { inherit pkgs; };
in
{
  environment = {
    shells = with pkgs; [
      bash
      zsh
    ];
    systemPackages = with pkgs; [
      coreutils
      # Custom scripts
      scripts.nix-cleanup
    ];
    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];

    # Environment variables for consistent shell experience in development environments
    variables = {
      # Ensure zsh is used in development environments
      SHELL = "${pkgs.zsh}/bin/zsh";

      # Set user's home directory for development environments
      USER_HOME = "/Users/${user}";

      # Ensure development environments can find zsh configuration
      ZDOTDIR = "/Users/${user}";

      # Make sure development shells load the user's zsh configuration
      NIX_SHELL_PRESERVE_PROMPT = "1";
    };

    # Shell initialization that will be available to all shells
    shellInit = ''
      # Ensure development environments use zsh with user configuration
      if [ -n "$IN_NIX_SHELL" ] || [ -n "$DIRENV_IN_ENVRC" ]; then
        # If we're in a development environment and not already in zsh
        if [ "$0" != "zsh" ] && [ -z "$ZSH_VERSION" ] && command -v zsh >/dev/null 2>&1; then
          # Switch to zsh with user configuration
          export SHELL="${pkgs.zsh}/bin/zsh"
          if [ -f "/Users/${user}/.zshrc" ]; then
            exec zsh -l
          fi
        fi
      fi
    '';
  };
}

