{ pkgs, ... }: {
  # .zshenv
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # enableVteIntegration = true;

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
      nixswitch = "darwin-rebuild switch --flake /etc/nix-darwin/.#";
      nixup = "pushd /etc/nix-darwin; nix flake update; nixswitch; popd";

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
      # ls = "ls --color=auto";
      # ll = "ls -lahrts";
      # l = "ls -l";

      cat = "bat";
      watch = "hwatch";
      
      # vi = "nvim";
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
}
