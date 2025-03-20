{
  pkgs,
  lib,
  config,
  ...
}: {
  # Configure zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      save = 1000000;
      size = 1000000;
    };
    
    shellAliases = {
      # Nix shortcuts
      nixswitch = "darwin-rebuild switch --flake /etc/nix-darwin/.# --show-trace -L -vv";
      nixup = "pushd /etc/nix-darwin; nix flake update; nixswitch; popd";
      nomb = "nom build /etc/nix-darwin/.#darwinConfigurations.jessup-mbp.config.system.build.toplevel";

      # Git shortcuts
      g = "git";
      gs = "git status -sb";
      gd = "git diff";
      gl = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      
      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      ls = "eza --icons";
      ll = "eza -lah --icons --git";
      tree = "eza --tree --icons";
      
      # Other
      watch = "hwatch";
      python = "python3";
      docker-clean = "docker rmi $(docker images -f 'dangling=true' -q)";
    };
    
    sessionVariables = {
      ARTIFACTORY_USER = "jessup";
      ASDF_DATA_DIR = "$HOME/.asdf";
    };
    
    oh-my-zsh = {
      enable = true;
      extraConfig = builtins.readFile ./extraConfig.zsh;
      plugins = [ 
        "aws"
        "brew"
        "git" 
        "direnv"
        "docker" 
        "kubectl" 
        "terraform" 
        "history" 
        "history-substring-search" 
      ];
    };
  };
  
  # Configure starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
    };
  };
  
  # Configure direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
} 