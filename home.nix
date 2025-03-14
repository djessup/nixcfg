# User-specific configuration
{ pkgs, ... }: {

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.11";

  home.packages = with pkgs; [ 
    nix-direnv
    nixfmt-rfc-style
    nil
    git
    awscli
    direnv
    git
    htop
    wget
    ripgrep
    jq
    sops
    probe-rs
    
  ];
  
  programs = {
    # https://github.com/nix-community/nix-direnv
    direnv = {
      enable = true;
      enableZshIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
  
    zsh = {
      enable = true;

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
          "direnv"
        ];
      };

      autocd = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      syntaxHighlighting.enable = true;

      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
      };

      shellAliases = {
        ll = "ls -l";
        ".." = "cd ..";
      };

    };

    dircolors.enable = true;
    fzf.enable = true;
    starship.enable = true;
    # zoxide.enable = true;

      # initExtra = ''
      #   # Enable iTerm2 shell integration.
      #   test -e "~/.iterm2_shell_integration.zsh" && source "~/.iterm2_shell_integration.zsh"
      # '';
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

}