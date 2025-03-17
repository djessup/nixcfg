{ pkgs, ... }:
{
  packages = with pkgs; [
    #
    # Nix development tools
    #
    nix-direnv                   # Direnv integration with Nix
    nixfmt-rfc-style             # Nix code formatter
    nil                          # Nix language server
    
    #
    # Shell utilities and enhancements
    #
    nix-zsh-completions          # Zsh completions for Nix
    zsh-completions              # Additional completions for Zsh
    zsh-better-npm-completion    # Improved NPM completions for Zsh
    zsh-fzf-tab                  # Tab completion with FZF for Zsh
    zsh-fzf-history-search       # History search with FZF for Zsh
    eza                          # Modern replacement for ls
    direnv                       # Environment manager
    htop                         # Interactive process viewer
    btop                         # Resource monitor
    wget                         # File downloader
    ripgrep                      # Fast grep
    jq                           # JSON processor
    yq                           # YAML processor
    sshpass                      # Non-interactive ssh password auth
    tree                         # Directory structure visualizer
    watch                        # Execute commands periodically
    hwatch                       # Modern watch command
    coreutils                    # GNU core utilities
    fzf                          # Fuzzy finder
    
    #
    # AWS tools
    #
    awscli2                      # AWS command line interface v2
    aws-sam-cli                  # AWS Serverless Application Model CLI
    awslogs                      # AWS CloudWatch logs viewer
    aws-gate                     # AWS SSH and port forwarding
    aws-shell                    # AWS shell
    aws-vault                    # AWS credentials manager
    aws-rotate-key               # AWS access key rotator
    nodePackages.aws-cdk         # AWS Cloud Development Kit
    okta-aws-cli                 # Okta authentication for AWS
    cw                           # CloudWatch logs tool
    
    #
    # Infrastructure and deployment
    #
    packer                       # Machine image builder
    terraform                    # Infrastructure as code
    k9s                          # Kubernetes CLI UI
    cloudlens                    # Cloud resource explorer
    kubectl                      # Kubernetes command line
    
    #
    # Azure tools
    #
    azure-cli                    # Azure command line interface
    azure-storage-azcopy         # Azure file transfer utility
    
    #
    # Development tools
    #
    git                          # Version control system
    gh                           # GitHub CLI
    openssl                      # SSL/TLS toolkit
    ngrok                        # Secure tunneling
    aiac                         # AI Assisted coding
    localstack                   # Local AWS cloud stack
    asciinema                    # Terminal recorder
    httpie                       # HTTP client
    skopeo                       # Container image tool
    sops                         # Secrets management
    age                          # File encryption
    qemu                         # Machine emulator
    sonar-scanner-cli            # Code quality scanner
    minicom                      # Serial communication program
    graphviz                     # Graph visualization
    
    #
    # Programming languages and environments
    #
    uv                           # Python package manager
    python3                      # Python language
    micromamba                   # Conda package manager
    asdf                         # Multi-runtime version manager
    asdf-vm                      # Version manager
    pnpm                         # Fast npm alternative
    
    # Java (uncomment as needed)
    # jdk11
    # openjdk8
    # jdk17
    # jdk21
    
    #
    # Embedded development
    #
    avrdude                      # AVR programmer
    autoconf                     # Source config creator
    automake                     # Makefile generator
    pkgconf                      # Package compiler configuration
    cmake                        # Build system generator
    ninja                        # Build system
    dfu-util                     # Device firmware upgrade
    openocd                      # On-chip debugger
    llvm                         # Compiler infrastructure
    probe-rs                     # Embedded debugging toolkit
    SDL2                         # Simple DirectMedia Layer
    zlib                         # Compression library
    gcc-arm-embedded             # ARM compiler
    rustup                       # Rust toolchain installer
    
    #
    # Rust tools
    #
    cargo-diet                   # Crate size optimizer
    cargo-bloat                  # Find code bloat
    rust-motd                    # Message of the day
    git-cliff                    # Changelog generator
    
    #
    # Applications and IDEs
    #
    raycast                      # Productivity launcher
    iterm2                       # Terminal emulator
    jetbrains.writerside         # Documentation IDE
    jetbrains.clion              # C/C++ IDE
    jetbrains.idea-ultimate      # JVM/general IDE
    jetbrains.rust-rover         # Rust IDE
    utm                          # Virtual machines
    warp-terminal                # Modern terminal
    code-cursor                  # AI code editor
    vscode                       # Code editor
    slack                        # Team communication
    darwin.lsusb                 # USB device lister
    
    #
    # Fonts
    #
    nerd-fonts.jetbrains-mono    # Developer font with icons
    font-awesome                 # Icon font
    hack-font                    # Programmer font
    noto-fonts                   # Google font family
    noto-fonts-emoji             # Emoji font
    meslo-lgs-nf                 # Powerline font
    
    #
    # Utilities
    #
    dockutil                     # macOS dock utility
  ];
}