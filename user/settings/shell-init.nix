{ config, pkgs, user, ... }:
{
  # Create shell initialization scripts for development environments
  home.file = {
    # Development environment shell configuration
    ".dev_shell_init".text = ''
      #!/usr/bin/env zsh
      # Development environment shell initialization
      # This script ensures consistent shell experience in nix-shell, nix develop, and direnv

      # Set development environment indicators
      export IN_DEV_SHELL=1
      export DEV_ENV_ACTIVE=1

      # Ensure we're using zsh
      if [[ -z "$ZSH_VERSION" ]] && command -v zsh >/dev/null 2>&1; then
        export SHELL="$(command -v zsh)"
        # If we're not already in zsh, switch to it
        if [[ "$0" != *"zsh"* ]]; then
          exec zsh -l
        fi
      fi

      # Source user's zsh configuration if available and not already sourced
      if [[ -n "$ZSH_VERSION" && -f "$HOME/.zshrc" && -z "$ZSHRC_SOURCED" ]]; then
        export ZSHRC_SOURCED=1
        source "$HOME/.zshrc"
      fi

      # Ensure Oh My Zsh is loaded if available
      if [[ -n "$ZSH_VERSION" && -d "$HOME/.oh-my-zsh" && -z "$OH_MY_ZSH_LOADED" ]]; then
        export ZSH="$HOME/.oh-my-zsh"
        if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
          export OH_MY_ZSH_LOADED=1
          source "$ZSH/oh-my-zsh.sh"
        fi
      fi

      # Load development-specific aliases and functions
      if [[ -f "$HOME/.dev_aliases" ]]; then
        source "$HOME/.dev_aliases"
      fi

      # Ensure direnv is properly initialized
      if command -v direnv >/dev/null 2>&1; then
        eval "$(direnv hook zsh)"
      fi

      # Set up development environment prompt if not preserved
      if [[ -z "$NIX_SHELL_PRESERVE_PROMPT" && -n "$IN_NIX_SHELL" ]]; then
        export PS1="(nix-shell) $PS1"
      elif [[ -z "$NIX_SHELL_PRESERVE_PROMPT" && -n "$DIRENV_IN_ENVRC" ]]; then
        export PS1="(direnv) $PS1"
      fi
    '';

    # Development-specific aliases and functions
    ".dev_aliases".text = ''
      # Development environment specific aliases and functions

      # Quick development environment commands
      alias dev-status='echo "Development Environment Status:"; echo "IN_NIX_SHELL: $IN_NIX_SHELL"; echo "DIRENV_IN_ENVRC: $DIRENV_IN_ENVRC"; echo "IN_DEV_SHELL: $IN_DEV_SHELL"; echo "SHELL: $SHELL"; echo "ZSH_VERSION: $ZSH_VERSION"'
      alias dev-reload='source ~/.dev_shell_init'

      # Enhanced development commands
      alias nix-shell-zsh='nix-shell --command zsh'
      alias nix-develop-zsh='nix develop --command zsh'

      # Function to enter a nix-shell with zsh and full configuration
      nix-shell-full() {
        nix-shell "$@" --command "source ~/.dev_shell_init && zsh"
      }

      # Function to enter nix develop with zsh and full configuration
      nix-develop-full() {
        nix develop "$@" --command "source ~/.dev_shell_init && zsh"
      }

      # Function to check if we're in a development environment
      in-dev-env() {
        if [[ -n "$IN_NIX_SHELL" || -n "$DIRENV_IN_ENVRC" || -n "$IN_DEV_SHELL" ]]; then
          return 0
        else
          return 1
        fi
      }

      # Function to show current development environment context
      dev-context() {
        if in-dev-env; then
          echo "🔧 Development Environment Active"
          if [[ -n "$IN_NIX_SHELL" ]]; then
            echo "  Type: nix-shell"
            echo "  Name: ''${name:-unknown}"
          elif [[ -n "$DIRENV_IN_ENVRC" ]]; then
            echo "  Type: direnv"
            echo "  Directory: $PWD"
          elif [[ -n "$IN_DEV_SHELL" ]]; then
            echo "  Type: development shell"
          fi
          echo "  Shell: $SHELL"
          echo "  ZSH Version: ''${ZSH_VERSION:-not available}"
        else
          echo "❌ No development environment detected"
        fi
      }
    '';
  };

  # Add shell initialization to session variables
  home.sessionVariables = {
    DEV_SHELL_INIT = "$HOME/.dev_shell_init";
  };

  # Install .envrc template for projects
  home.file.".envrc-template".source = ./envrc-template;
}
