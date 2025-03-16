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
      ls = "ls --color=auto";
      ll = "ls -lahrts";
      l = "ls -l";
      # vi = "nvim";
      python = "python3";
      # k = "kubectl";
      # tmux = "TERM=screen-256color-bce tmux";
      # ocaml = "rlwrap ocaml";
      docker-clean = "docker rmi $(docker images -f 'dangling=true' -q)";
    };

    sessionVariables = {
      ARTIFACTORY_USER = "jessup";
    };
    
    initExtra = ''
      export TERM=xterm-256color
      # export LANG=en_US.UTF-8

      . "$HOME/.asdf/asdf.sh"
      source <(kubectl completion zsh)
     
      # Additional completions
      fpath+=($HOME/.zfunc)

      # amstool completions
      # source $HOME/.zfunc/_amstool
      # uv completions
      # source $HOME/.zfunc/_uv

      # jenv
      export PATH="$HOME/.jenv/bin:$PATH"
      eval "$(jenv init -)"

      # NVM
      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
      # [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

      # SDKMAN
      export SDKMAN_DIR="$HOME/.sdkman"
      [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
      
      # iTerm2 shell integration
      [[ -s "$HOME/.iterm2_shell_integration.zsh" ]] && source "$HOME/.iterm2_shell_integration.zsh"
      
      # Ok, if Nix doesn't work, try this:
      # export PATH="/run/current-system/sw/bin:$PATH"
      # And enable this
      # if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      #   . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      # fi
      '';

    oh-my-zsh = {
      enable = true;
      theme = "spaceship";
      plugins = [ 
        "aws"
        "git" 
        "direnv"
        "docker" 
        "kubectl" 
        "asdf" 
        "terraform" 
        "history" 
        "history-substring-search" 
      ];
    };
  };
}
