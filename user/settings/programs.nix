{ config, pkgs, ... }:
{
  # Add ~/.local/bin to PATH for tools like uv, rye, etc.
  home.sessionPath = [ "$HOME/.local/bin" ];

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true; # see note on other shells below
      nix-direnv.enable = true;

      # Configuration to ensure consistent shell environment
      config = {
        global = {
          # Preserve shell environment when entering development environments
          strict_env = false;
          # Load user's shell configuration in development environments
          load_dotenv = true;
        };
      };

      # Shell hooks to ensure zsh configuration is loaded
      stdlib = ''
        # Function to ensure zsh configuration is loaded in development environments
        use_zsh_config() {
          # Source user's zsh configuration if available
          if [[ -f "$HOME/.zshrc" && -n "$ZSH_VERSION" ]]; then
            source "$HOME/.zshrc"
          fi

          # Ensure Oh My Zsh is loaded if available
          if [[ -n "$ZSH_VERSION" && -d "$HOME/.oh-my-zsh" ]]; then
            export ZSH="$HOME/.oh-my-zsh"
            if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
              source "$ZSH/oh-my-zsh.sh"
            fi
          fi
        }

        # Function to set up development environment with zsh
        use_dev_shell() {
          # Ensure we're using zsh
          if [[ -z "$ZSH_VERSION" ]] && command -v zsh >/dev/null 2>&1; then
            export SHELL="$(command -v zsh)"
          fi

          # Load zsh configuration
          use_zsh_config

          # Set development environment indicators
          export IN_DEV_SHELL=1
          export DIRENV_IN_ENVRC=1
        }
      '';
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

    # Let home Manager install and manage itself.
    home-manager.enable = true;
  };
}
