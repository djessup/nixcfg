{ pkgs, ... }:
{
  packages = with pkgs; [
    #
    # Nix development tools
    #
    home-manager # Home manager
    nil # Nix language server
    nix-direnv # Direnv integration with Nix
    nix-inspect # Nix inspector
    nix-output-monitor # Nix output monitor
    nix-search # Nix package search
    nixd # Nix language server
    nixfmt-rfc-style # Nix code formatter

    #
    # Shell utilities and enhancements
    #
    bats # Bash test harness
    btop # Resource monitor
    coreutils # GNU core utilities
    direnv # Environment manager
    dust # Disk usage analyzer
    eza # Modern replacement for ls
    fd # Fast directory listing
    fortune # Fortune cookie
    fzf # Fuzzy finder
    gawkInteractive # Interactive gawk
    htop # Interactive process viewer
    hwatch # Modern watch command
    jq # JSON processor
    lolcat # Rainbows and unicorns!
    makerpm # simple rpm package builder
    ncdu # Disk usage analyzer
    neo-cowsay # Go port of cowsay
    nfpm # deb and rpm package builder
    nix-zsh-completions # Zsh completions for Nix
    nodePackages.neovim # Neovim Node runtime
    ripgrep # Fast grep
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
    aws-iam-authenticator # Authenticate to EKS with IAM
    aws-rotate-key # AWS access key rotator
    pkgsStable.aws-sam-cli # AWS Serverless Application Model CLI
    aws-vault # AWS credentials manager
    awscli2 # AWS command line interface v2
    awslogs # AWS CloudWatch logs viewer
    cw # CloudWatch logs tool
    eksctl # EKS cluster management
    nodePackages.aws-cdk # AWS Cloud Development Kit

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
    google-cloud-sdk # Google Cloud Platform (GCP) CLI
    k9s # Kubernetes CLI UI
    kubectl # Kubernetes command line
    opentofu # OpenTofu (Terraform alternative)
    packer # Machine image builder
    terraform # Infrastructure as code
    terraform-compliance # Terraform compliance testing
    terraform-docs # Generate documentation for Terraform modules
    terraform-landscape # Terraform code formatter
    terraformer # Infrastructure as code generator
    terraforming # Export existing cloud resources to Terraform
    pkgsStable.terragrunt # Terraform wrapper for managing multiple modules
    tflint # Terraform linter
    tfsec # Terraform security scanner
    trunk-io # Trunk.io CLI (polyglot linter, formatter, etc)

    #
    # Development tools
    #
    # inputs.mise-flake.packages.${system}.mise # Mise-in-place dev environment manager
    age # File encryption
    ant # ant build tool
    asciinema # Terminal recorder
    circleci-cli # CircleCI CLI
    docker-compose
    doxygen # Documentation generator
    gh # GitHub CLI
    git # Version control system
    git-cliff # Changelog generator
    git-extras # Git extras
    git-lfs # Git Large File Storage
    github-runner # Self-hosted GitHub Runner
    gnumake # GNU make
    go # Go programming language
    graphviz # Graph visualization
    httpie # HTTP client
    kubernetes-helm # Helm package manager for Kubernetes
    libcoap # CoAP library
    localstack # Local AWS cloud stack
    minicom # Serial communication program
    mosquitto # MQTT broker
    ngrok # Secure tunneling
    openssl # SSL/TLS toolkit
    qemu # Machine emulator
    rlwrap # Readline wrapper
    rops # SOPS in Rust
    shellcheck # Shell script linter
    shfmt # Shell script formatter
    skopeo # Container image tool
    sonar-scanner-cli # Code quality scanner
    sops # Secrets management
    srecord # Collection of tools for manipulating EEPROM load files
    zig # Zig programming language
    
    #
    # Database tools
    #
    sqlite # Official SQLite CLI
    sqlite-utils # SQLite utilities
    sqlitebrowser # SQLite database browser
    sqlite-web # Web-based SQLite database browser
#    sqlite-interactive # Interactive SQLite shell
    sqlite-analyzer # SQLite database analyzer
    github-to-sqlite # Save data from GitHub to SQLite

    #
    # AI tools
    #
    claude-code # Claude CLI
    pkgsStable.ollama # LLM runtime
    opencode # AI TUI
    oterm # Ollama terminal client

    #
    # Node.js tools
    #
    nodejs # Node.js runtime
    pnpm # Fast npm alternative
    bun # Fast npm alternative

    #
    # Python tools
    #
    hatch # Modern Python toolchain
    pkgsStable.micromamba # Conda package manager
    pixi # Polyglot package manager
    poetry # Python packager and dependency manager
    python3 # Python language
    rye # Python toolchain
    uv # Python package manager
    virtualenv # Python virtual environment

    #
    # Java JDKs
    #
    # jdk11
    # jdk21
    # openjdk8
    jdk17

    #
    # Embedded dev
    #
    # gcc-arm-embedded # ARM compiler (disabled due to issues with porting.info)
    autoconf # Source config creator
    automake # Makefile generator
    avrdude # AVR programmer
    cmake # Build system generator
    dfu-util # Device firmware upgrade
    libtool
    llvm
    # mspdebug # MSP430 programmer, debugger, gdb proxy
    # mspds-bin # MSP430 debugger (binary version)
    ninja # Build system
    # nrf5-sdk # Nordic SDK
    # openocd # On-chip debugger (disabled due to SDL dependency issue)
    pkgconf # Package compiler configuration
    probe-rs-tools # Embedded debugging toolkit
    zlib # Compression library
    SDL2 # Simple DirectMedia Layer

    #
    # Rust dev
    #
    cargo-bloat # Find code bloat
    cargo-diet # Crate size optimizer
    rust-motd # Message of the day
    rustup # Rust toolchain installer

    #
    # Applications / IDEs
    #
    #    code-cursor                  # AI code editor (disabled in favour of unmanaged version for faster updates)
    goose-cli # Goose AI IDE (open LLM-assisted IDE)
    iterm2 # Terminal emulator
    # jetbrains.aqua # Polyglot IDE
    # jetbrains.clion # C/C++ IDE
    # jetbrains.datagrip # Database IDE
    jetbrains.idea # JVM/general IDE
    jetbrains.pycharm # Python IDE
    jetbrains.rust-rover # Rust IDE
    keka # Multi-format (un)archiver
    neovide # Neovim GUI
    notion-app # Notion workspace
    obsidian # Knowledge base
    obsidian-export # Obsidian vault export tool
    # raycast # Productivity launcher (disabled due to version lag, now install via brew)
    # signal-desktop-bin # Signal messaging (disabled, using brew instead)
    slack # Team communication
    utm # Virtual machines
    vlc-bin # VLC media player
    vscode # Code editor
    # warp-terminal # Modern terminal

    #
    # Fonts
    #
    font-awesome # Icon font
    hack-font # Programmer font
    meslo-lgs-nf # Powerline font
    monaspace # Monaspace https://monaspace.githubnext.com/
    nerd-fonts.monaspace # Monaspace font with icons
    nerd-fonts.jetbrains-mono # Developer font with icons
    noto-fonts # Google font family
    noto-fonts-color-emoji # Emoji font

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
    pinentry_mac # Secure pin/passphrase input for GPG
  ];
}
