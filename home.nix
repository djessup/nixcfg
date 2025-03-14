# User-specific configuration
{ config, pkgs, lib, home-manager, ... }:

let
  user = "jessup";
  # Define the content of your file as a derivation
  # myEmacsLauncher = pkgs.writeScript "emacs-launcher.command" ''
  #   #!/bin/sh
  #     emacsclient -c -n &
  # '';
  # sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  # additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
   ./dock
  ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [ 
    # Nix
    nix-direnv
    nixfmt-rfc-style
    nil
    # Shell
    
    nix-zsh-completions
    zsh-completions
    zsh-better-npm-completion
    # zsh-history
    zsh-fzf-tab
    zsh-fzf-history-search
    # AWS
    awscli2
    aws-sam-cli
    awslogs
    aws-gate
    aws-shell
    aws-vault
    aws-rotate-key
    nodePackages.aws-cdk
    okta-aws-cli
    cw
    packer
    k9s
    cloudlens
    # Azure
    azure-cli
    azure-storage-azcopy
    # Misc tools
    darwin.lsusb
    git
    direnv
    htop
    btop
    wget
    ripgrep
    jq
    yq
    sshpass
    tree
    watch
    hwatch
    skopeo
    sops
    qemu
    sonar-scanner-cli
    minicom
    coreutils
    openssl
    ngrok
    aiac
    # airgorah
    localstack
    
    # ghidra
    
    # Python
    uv
    python3
    # python313
    # python39
    micromamba

    # Java
    # jdk11
    # openjdk8
    # jdk17
    # jdk21
    visualvm

    # jetbrains.writerside
    # jetbrains.clion
    # jetbrains.idea-ultimate
    # jetbrains.rust-rover
    # jetbrains-toolbox
    # Fonts
    nerd-fonts.jetbrains-mono

    # Embedded
    avrdude
    # ravedude
    # simulide
    autoconf
    automake
    pkgconf
    cmake
    ninja
    dfu-util
    openocd
    llvm
    probe-rs
    SDL2
    qemu
    gcc-arm-embedded
    # libuv
    # libssh
    # libssh2
    # libusb
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
          "zsh-fzf-tab"
        ];
  
      };
      
      autocd = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      syntaxHighlighting.enable = true;
      # enableBashCompletion = true;
      # enableLsColors = true;
      # enableGlobalCompInit = true;
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
    # starship.enable = true;
    # zoxide.enable = true;

      # initExtra = ''
      #   # Enable iTerm2 shell integration.
      #   test -e "~/.iterm2_shell_integration.zsh" && source "~/.iterm2_shell_integration.zsh"
      # '';
  };



  # Fully declarative dock using the latest from Nix Store
  local = {
    dock.enable = true;
    dock.entries = [
      { path = "${pkgs.iterm2}/Applications/iTerm.app/"; }
      { path = "${pkgs.warp-terminal}/Applications/Warp.app/"; }
      { path = "${pkgs.code-cursor}/Applications/Cursor.app/"; }
      { path = "/Applications/Microsoft Teams.app/"; }
      { path = "/Applications/Slack.app/"; }
      { path = "/Applications/Outlook.app/"; }
      { path = "/Applications/Microsoft Edge.app/"; }
      { path = "/Applications/System Settings.app/"; }
      { path = "/Applications/Github Desktop.app/"; }
      { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
      { path = "/System/Applications/Podcasts.app/"; }
      { path = "/Applications/ChatGPT.app/"; }

      { path = "${pkgs.jetbrains.idea-ultimate}/Applications/IntelliJ IDEA.app/"; }
      { path = "${pkgs.jetbrains.clion}/Applications/CLion.app/"; }
      { path = "${pkgs.jetbrains.rust-rover}/Applications/RustRover.app/"; }
      {
        path = "/Applications";
        section = "others";
        options = "--sort name --view grid --display folder";
      }
      {
        path = "${config.users.users.${user}.home}/Downloads";
        section = "others";
        options = "--sort name --view grid --display stack";
      }
    ];
  };

}