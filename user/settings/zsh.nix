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
      nixbuild = "darwin-rebuild build --flake /etc/nix-darwin/.# --show-trace -L -v |& nom";
      nixswitch = "sudo darwin-rebuild switch --flake /etc/nix-darwin/.# --show-trace -L -v |& nom";
      nixfluff = "nix flake --log-format internal-json -v update |& nom --json";
      nixup = "pushd /etc/nix-darwin; nixfluff; nixswitch; popd";
      nombuild = "nom build /etc/nix-darwin/.#darwinConfigurations.jessup-m3.config.system.build.toplevel";

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

      # cat = "bat";
      watch = "hwatch";

      # Editor shortcuts
      # vi = "nvim";
      cursor = "/Applications/Cursor.app/Contents/MacOS/Cursor";
      python = "python3";
      docker-clean = "docker rmi $(docker images -f 'dangling=true' -q)";

      tfgo = "terraform plan -out tfplan && terraform apply tfplan";
    };

    sessionVariables = {
      ARTIFACTORY_USER = "jessup";
      ASDF_DATA_DIR = "$HOME/.asdf";
      TERM = "xterm-256color";
      LANG = "en_US.UTF-8";
    };

    oh-my-zsh = {
      enable = true;
      extraConfig = builtins.readFile ./extraConfig.zsh;
      plugins = [
        "aws"
        "brew"
        "direnv"
        "docker"
        "fzf"
        "git"
        "history"
        "iterm2"
        "kubectl"
        "macos"
        "terraform"
        "zsh-interactive-cd"
      ];
    };
  };
}
