{ inputs, pkgs, ... }:{
  packages = with pkgs; [
    #
    # Nix development tools
    #
    nil # Nix language server
    nixd # Nix language server
    nix-direnv # Direnv integration with Nix
    nixfmt-rfc-style # Nix code formatter
    nix-inspect # Nix inspector
    nix-output-monitor # Nix output monitor
    home-manager # Home manager
    nix-search # Nix package search

    #
    # Shell utilities and enhancements
    #
    btop # Resource monitor
    coreutils # GNU core utilities
    dust # Disk usage analyzer
    direnv # Environment manager
    eza # Modern replacement for ls
    fd # Fast directory listing
    fortune # Fortune cookie
    fzf # Fuzzy finder
    gawkInteractive # Interactive gawk
    htop # Interactive process viewer
    hwatch # Modern watch command
    jq # JSON processor
    lolcat # Rainbows and unicorns!
    ncdu # Disk usage analyzer
    neo-cowsay # Go port of cowsay
    nodePackages.neovim # Neovim Node runtime
    nix-zsh-completions # Zsh completions for Nix
    ripgrep # Fast grep
    nfpm # deb and rpm package builder
    makerpm # simple rpm package builder
    sshpass # Non-interactive ssh password auth
    tree # Directory structure visualizer
    watch # Execute commands periodically
    wget # File downloader
    yq # YAML processor
    zsh-better-npm-completion # Improved NPM completions for Zsh
    zsh-completions # Additional completions for Zsh
    zsh-fzf-history-search # History search with FZF for Zsh
    zsh-fzf-tab # Tab completion with FZF for Zsh

    #
    # AWS tools
    #
    aws-gate # AWS SSH and port forwarding
    aws-rotate-key # AWS access key rotator
    aws-sam-cli # AWS Serverless Application Model CLI
    aws-shell # AWS shell
    aws-vault # AWS credentials manager
    awscli2 # AWS command line interface v2
    awslogs # AWS CloudWatch logs viewer
    cw # CloudWatch logs tool
    eksctl # EKS cluster management
    aws-iam-authenticator # Authenticate to EKS with IAM
    nodePackages.aws-cdk # AWS Cloud Development Kit
    okta-aws-cli # Okta authentication for AWS

    #
    # Azure tools
    #
    azure-cli # Azure command line interface
    azure-storage-azcopy # Azure file transfer utility

    #
    # Infrastructure and deployment
    #
    atmos # Infrastructure as code tool
    checkov # Static code analysis for Terraform
    cloudlens # Cloud resource explorer
    k9s # Kubernetes CLI UI
    kubectl # Kubernetes command line
    opentofu # OpenTofu (Terraform alternative)
    packer # Machine image builder
    terraform # Infrastructure as code
    terraformer # Infrastructure as code generator
    terraforming # Export existing cloud resources to Terraform
    terraform-docs # Generate documentation for Terraform modules
    terraform-landscape # Terraform code formatter
    terraform-compliance # Terraform compliance testing
    terragrunt # Terraform wrapper for managing multiple modules
    tfsec # Terraform security scanner
    tflint # Terraform linter
    trunk-io # Trunk.io CLI (polyglot linter, formatter, etc)



    #
    # Development tools
    #
    age # File encryption
    aiac # AI Assisted coding
    ant # ant build tool
    asciinema # Terminal recorder
    doxygen # Documentation generator
    docker-compose
    gh # GitHub CLI
    git # Version control system
    git-cliff # Changelog generator
    gnumake # GNU make
    graphviz # Graph visualization
    kubernetes-helm # Helm package manager for Kubernetes
    httpie # HTTP client
    localstack # Local AWS cloud stack
    libcoap # CoAP library
    minicom # Serial communication program
    inputs.mise-flake.packages.${system}.mise
    mosquitto # MQTT broker
    ngrok # Secure tunneling
    openssl # SSL/TLS toolkit
    qemu # Machine emulator
    rlwrap # Readline wrapper
    skopeo # Container image tool
    sonar-scanner-cli # Code quality scanner
    sops # Secrets management
    srecord # Collection of tools for manipulating EEPROM load files
    rops # SOPS in Rust

    #
    # Database tools
    #
    sqlite # Official SQLite CLI
    sqlite-utils # SQLite utilities
    sqlitebrowser # SQLite database browser
    sqlite-web # Web-based SQLite database browser
    sqlite-interactive # Interactive SQLite shell
    sqlite-analyzer # SQLite database analyzer
    github-to-sqlite # Save data from GitHub to SQLite
    litecli # SQLite CLI with autocompletion and syntax highlighting

    #
    # AI tools
    #
    ollama # LLM runtime

    #
    # Programming languages and environments
    #
    micromamba # Conda package manager
    nodejs # Node.js runtime
    pnpm # Fast npm alternative
    poetry # Python packager and dependency manager
    python3 # Python language
    virtualenv # Python virtual environment
    uv # Python package manager
    pixi # Polyglot package manager

    # Java (uncomment as needed)
    # jdk11
    jdk17
    # jdk21
    # openjdk8

    #
    # Embedded development
    #
    autoconf # Source config creator
    automake # Makefile generator
    avrdude # AVR programmer
    cmake # Build system generator
    dfu-util # Device firmware upgrade
    # gcc-arm-embedded # ARM compiler (disabled due to issues with porting.info)
    libtool
    llvm
    mspdebug # MSP430 programmer, debugger, gdb proxy
    mspds-bin # MSP430 debugger (binary version)
    ninja # Build system
    nrf5-sdk # Nordic SDK
    openocd # On-chip debugger
    pkgconf # Package compiler configuration
    probe-rs # Embedded debugging toolkit
    SDL2 # Simple DirectMedia Layer
    zlib # Compression library

    #
    # Rust development
    #
    cargo-bloat # Find code bloat
    cargo-diet # Crate size optimizer
    rust-motd # Message of the day
    rustup # Rust toolchain installer

    #
    # Applications and IDEs
    #
    #    code-cursor                  # AI code editor (disabled in favour of unmanaged version for faster updates)
    iterm2 # Terminal emulator
    jetbrains.clion # C/C++ IDE
    jetbrains.idea-ultimate # JVM/general IDE
    jetbrains.rust-rover # Rust IDE
    jetbrains.datagrip # Database IDE
    jetbrains.writerside # Documentation IDE
    keka # Multi-format (un)archiver
    neovide # Neovim GUI
    obsidian # Knowledge base
    raycast # Productivity launcher
    slack # Team communication
    utm # Virtual machines
    vlc-bin # VLC media player
    vscode # Code editor
    warp-terminal # Modern terminal

    #
    # Fonts
    #
    font-awesome # Icon font
    hack-font # Programmer font
    meslo-lgs-nf # Powerline font
    nerd-fonts.jetbrains-mono # Developer font with icons
    noto-fonts # Google font family
    noto-fonts-emoji # Emoji font

    #
    # Utilities
    #
    darwin.lsusb # USB device lister
    dockutil # macOS dock utility
    sox # Sound processing tool

    #
    # Security tools
    #
    bws # Official Bitwarden Secrets Manager CLI
    rbw # Unofficial Rust-based Bitwarden client
    vaultwarden # Self-hosted Bitwarden server replacement
    pinentry_mac # Secure pin/passphrase input for GPG
    teleport # SSH and Kubernetes secure access manager
  ];
}
