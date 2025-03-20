{ pkgs, ... }:
{
  packages = with pkgs; [
    #
    # Nix development tools
    #
    nil                          # Nix language server
    nixd                         # Nix language server
    nix-direnv                   # Direnv integration with Nix
    nixfmt-rfc-style             # Nix code formatter
    nix-inspect                  # Nix inspector
    nix-output-monitor           # Nix output monitor
    home-manager                 # Home manager
    
    #
    # Shell utilities and enhancements
    #
    btop                         # Resource monitor
    coreutils                    # GNU core utilities
    direnv                       # Environment manager
    eza                          # Modern replacement for ls
    fzf                          # Fuzzy finder
    htop                         # Interactive process viewer
    hwatch                       # Modern watch command
    jq                           # JSON processor
    neovim                       # Vim-fork focused on extensibility and usability
    nodePackages.neovim          # Neovim Node runtime
    nix-zsh-completions          # Zsh completions for Nix
    ripgrep                      # Fast grep
    sshpass                      # Non-interactive ssh password auth
    tree                         # Directory structure visualizer
    watch                        # Execute commands periodically
    wget                         # File downloader
    yq                           # YAML processor
    zsh-better-npm-completion    # Improved NPM completions for Zsh
    zsh-completions              # Additional completions for Zsh
    zsh-fzf-history-search       # History search with FZF for Zsh
    zsh-fzf-tab                  # Tab completion with FZF for Zsh
    
    #
    # AWS tools
    #
    aws-gate                     # AWS SSH and port forwarding
    aws-rotate-key               # AWS access key rotator
    aws-sam-cli                  # AWS Serverless Application Model CLI
    aws-shell                    # AWS shell
    aws-vault                    # AWS credentials manager
    awscli2                      # AWS command line interface v2
    awslogs                      # AWS CloudWatch logs viewer
    cw                           # CloudWatch logs tool
    nodePackages.aws-cdk         # AWS Cloud Development Kit
    okta-aws-cli                 # Okta authentication for AWS
    
    #
    # Infrastructure and deployment
    #
    cloudlens                    # Cloud resource explorer
    k9s                          # Kubernetes CLI UI
    kubectl                      # Kubernetes command line
    packer                       # Machine image builder
    terraform                    # Infrastructure as code
    
    #
    # Azure tools
    #
    azure-cli                    # Azure command line interface
    azure-storage-azcopy         # Azure file transfer utility
    
    #
    # Development tools
    #
    age                          # File encryption
    aiac                         # AI Assisted coding
    asciinema                    # Terminal recorder
    gh                           # GitHub CLI
    git                          # Version control system
    git-cliff                    # Changelog generator
    graphviz                     # Graph visualization
    httpie                       # HTTP client
    localstack                   # Local AWS cloud stack
    minicom                      # Serial communication program
    ngrok                        # Secure tunneling
    openssl                      # SSL/TLS toolkit
    qemu                         # Machine emulator
    skopeo                       # Container image tool
    sonar-scanner-cli            # Code quality scanner
    sops                         # Secrets management
    rops                         # SOPS in Rust
    ollama                       # LLM runtime

    #
    # Programming languages and environments
    #
    asdf-vm                      # Version manager
    micromamba                   # Conda package manager
    nodejs                       # Node.js runtime
    
    pnpm                         # Fast npm alternative
    python3                      # Python language
    uv                           # Python package manager
    
    # Java (uncomment as needed)
    # jdk11
    # jdk17
    # jdk21
    # openjdk8
    
    #
    # Embedded development
    #
    autoconf                     # Source config creator
    automake                     # Makefile generator
    avrdude                      # AVR programmer
    cmake                        # Build system generator
    dfu-util                     # Device firmware upgrade
    gcc-arm-embedded             # ARM compiler
    llvm                         # Compiler infrastructure
    ninja                        # Build system
    openocd                      # On-chip debugger
    pkgconf                      # Package compiler configuration
    probe-rs                     # Embedded debugging toolkit
    SDL2                         # Simple DirectMedia Layer
    zlib                         # Compression library
    
    #
    # Rust tools
    #
    cargo-bloat                  # Find code bloat
    cargo-diet                   # Crate size optimizer
    rust-motd                    # Message of the day
    rustup                       # Rust toolchain installer
    
    #
    # Applications and IDEs
    #
    code-cursor                  # AI code editor
    iterm2                       # Terminal emulator
    jetbrains.clion              # C/C++ IDE
    jetbrains.idea-ultimate      # JVM/general IDE
    jetbrains.rust-rover         # Rust IDE
    jetbrains.writerside         # Documentation IDE
    neovide                      # Neovim GUI
    raycast                      # Productivity launcher
    slack                        # Team communication
    utm                          # Virtual machines
    vscode                       # Code editor
    warp-terminal                # Modern terminal
    
    #
    # Fonts
    #
    font-awesome                 # Icon font
    hack-font                    # Programmer font
    meslo-lgs-nf                 # Powerline font
    nerd-fonts.jetbrains-mono    # Developer font with icons
    noto-fonts                   # Google font family
    noto-fonts-emoji             # Emoji font
    
    #
    # Utilities
    #
    darwin.lsusb                 # USB device lister
    dockutil                     # macOS dock utility
    asitop                       # Apple Silicon System monitor

  ];
}