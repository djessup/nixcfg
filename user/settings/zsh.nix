{ ... }: {
  # .zshenv
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = ["brackets" "regexp" ];
    };

    # enableVteIntegration = true;

    history = {
      append = true;
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      saveNoDups = true;
      share = true;
      save = 1000000;
      size = 1000000;
    };

    shellAliases = {
      nixbuild = "darwin-rebuild build --flake /etc/nix-darwin/.# --show-trace -L -v |& nom";
      nixswitch = "sudo darwin-rebuild switch --flake /etc/nix-darwin/.# --show-trace -L -v |& nom";
      nixfluff = "nix flake --log-format internal-json -v update |& nom --json";
      nixup = "pushd /etc/nix-darwin; nixfluff; nixswitch; popd";
      nombuild = "nom build /etc/nix-darwin/.#darwinConfigurations.jessup-m3.config.system.build.toplevel";

      # Nix garbage collection and space optimization
      nix-gc = "nix-cleanup --user-only";  # Use the comprehensive cleanup script

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

      # Development environment variables
      NIX_SHELL_PRESERVE_PROMPT = "1";
      DIRENV_LOG_FORMAT = "";  # Reduce direnv noise
    };

    # Custom initialization for development environments
    initContent = ''
      # Development environment detection and setup
      if [[ -n "$IN_NIX_SHELL" || -n "$DIRENV_IN_ENVRC" || -n "$IN_DEV_SHELL" ]]; then
        # We're in a development environment
        export DEV_ENV_ACTIVE=1

        # Ensure prompt shows development environment status
        if [[ -z "$NIX_SHELL_PRESERVE_PROMPT" ]]; then
          export PS1="(dev) $PS1"
        fi

        # Load any development-specific aliases or functions
        if [[ -f "$HOME/.dev_aliases" ]]; then
          source "$HOME/.dev_aliases"
        fi
      fi

      # Ensure direnv is properly initialized in all contexts
      if command -v direnv >/dev/null 2>&1; then
        eval "$(direnv hook zsh)"
      fi

      function sft-connect() {
        local query=$1
        local target=$(sft list-servers -columns hostname | grep $query | head -n1)
        if [[ -z "''${target}" ]]; then
          echo "No matching server found"
          return 1
        fi
        echo "Connecting to ''${target}"
        sft ssh "''${target}"
      }
    '';

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
