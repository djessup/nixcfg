# User-specific configuration
{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}:
{
  imports = [
    ./settings/zsh.nix
  ];

  home.packages = with pkgs; [
    # Nix
    nix-direnv
    nixfmt-rfc-style
    nil
    # Shell
    nix-zsh-completions
    zsh-completions
    zsh-better-npm-completion
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
    terraform
    k9s
    cloudlens
    kubectl
    # Azure
    azure-cli
    azure-storage-azcopy
    # Misc tools
    eza
    darwin.lsusb
    asdf
    git
    gh
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
    asciinema
    httpie
    # thefuck
    # ghidra
    slack
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
    zlib
    qemu
    gcc-arm-embedded
    rustup
    # cargo
    cargo-diet
    cargo-bloat
    rust-motd
    
    # libuv
    # libssh
    # libssh2
    # libusb
    raycast
    iterm2
    jetbrains.writerside
    jetbrains.clion
    jetbrains.idea-ultimate
    jetbrains.rust-rover
    utm
    warp-terminal
    code-cursor
    vscode
    fzf
    asdf-vm
  ];

  programs = {

    direnv = {
      enable = true;
      enableZshIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

    dircolors.enable = true;

    # zoxide.enable = true;

    # starship = {
    #   enable = true;
    #   enableZshIntegration = true;
    # };

    bat = {
      enable = true;
      config.theme = "TwoDark";
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    eza.enable = true;

    git = {
      enable = true;
      lfs.enable = true;
      userName = "David Jessup";
      userEmail = "jessup@adobe.com";
      extraConfig = {
        init.defaultBranch = "master";
        credential."https://git.cloudmanager.adobe.com".provider = "generic";
      };
    };

    # Let home Manager install and manage itself.
    home-manager.enable = true;
  };

  home.file.".inputrc".source = ./settings/inputrc;

  # The state version is required and should stay at the version originally installed.
  home.stateVersion = "24.11";

}
