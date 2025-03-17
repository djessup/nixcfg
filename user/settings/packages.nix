{ pkgs, ... }:
{
  packages = with pkgs; [
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
    age
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
    font-awesome
    hack-font
    noto-fonts
    noto-fonts-emoji
    meslo-lgs-nf

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
    git-cliff
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
    pnpm
    graphviz
    dockutil
  ];
}