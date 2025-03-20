{
  pkgs,
  lib,
  config,
  ...
}: {
  # Install CLI utilities
  home.packages = with pkgs; [
    # Nix development tools
    nil                          # Nix language server
    nixd                         # Nix language server
    nix-direnv                   # Direnv integration with Nix
    nixfmt-rfc-style             # Nix code formatter
    nix-inspect                  # Nix inspector
    nix-output-monitor           # Nix output monitor
    home-manager                 # Home Manager CLI
    
    # Shell utilities and enhancements
    btop                         # Resource monitor
    coreutils                    # GNU core utilities
    direnv                       # Environment manager
    eza                          # Modern replacement for ls
    fzf                          # Fuzzy finder
    htop                         # Interactive process viewer
    hwatch                       # Modern watch command
    jq                           # JSON processor
    yq                           # YAML processor
    ripgrep                      # Fast grep
    sshpass                      # Non-interactive ssh password auth
    tree                         # Directory structure visualizer
    watch                        # Execute commands periodically
    wget                         # File downloader
    curl                         # URL retrieval
    rsync                        # File synchronization
    unzip                        # Zip file extractor
    delta                        # Git diff viewer
    
    # AWS tools
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
    
    # Infrastructure and deployment
    cloudlens                    # Cloud resource explorer
    k9s                          # Kubernetes CLI UI
    kubectl                      # Kubernetes command line
    packer                       # Machine image builder
    terraform                    # Infrastructure as code
    
    # Azure tools
    azure-cli                    # Azure command line interface
    azure-storage-azcopy         # Azure file transfer utility
    
    # Development tools
    age                          # File encryption
    aiac                         # AI Assisted coding
    asciinema                    # Terminal recorder
    gh                           # GitHub CLI
    git                          # Version control system
    git-cliff                    # Changelog generator
    graphviz                     # Graph visualization
    httpie                       # HTTP client
    just                         # Command runner
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
    
    # Programming languages and environments
    asdf-vm                      # Version manager
    micromamba                   # Conda package manager
    nodejs                       # Node.js runtime
    pnpm                         # Fast npm alternative
    python3                      # Python language
    rustup                       # Rust toolchain installer
    go                           # Go language
    uv                           # Python package manager
    
    # Embedded development
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
    
    # Rust tools
    cargo-bloat                  # Find code bloat
    cargo-diet                   # Crate size optimizer
    rust-motd                    # Message of the day
    
    # Applications and IDEs
    code-cursor                  # AI code editor
    iterm2                       # Terminal emulator
    jetbrains.clion              # C/C++ IDE
    jetbrains.idea-ultimate      # JVM/general IDE
    jetbrains.rust-rover         # Rust IDE
    jetbrains.writerside         # Documentation IDE
    neovide                      # Neovim GUI
    raycast                      # Productivity launcher
    utm                          # Virtual machines
    
    # Fonts
    font-awesome                 # Icon font
    hack-font                    # Programmer font
    meslo-lgs-nf                 # Powerline font
    nerd-fonts.jetbrains-mono    # Developer font with icons
    noto-fonts                   # Google font family
    noto-fonts-emoji             # Emoji font
    
    # Utilities
    darwin.lsusb                 # USB device lister
    dockutil                     # macOS dock utility
    asitop                       # Apple Silicon System monitor
    neofetch                     # System info display
    tldr                         # Simplified man pages
  ];
  
  # Configure neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    vimdiffAlias = true;
    
    # Basic configuration
    extraConfig = ''
      set number
      set relativenumber
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set smartindent
      set nowrap
      set incsearch
      set termguicolors
      set scrolloff=8
      set completeopt=menuone,noinsert,noselect
      set signcolumn=yes
      
      " Key bindings
      let mapleader = " "
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
    '';
  };
  
  # Configure Visual Studio Code
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      ms-vscode.cpptools
      ms-python.python
      redhat.vscode-yaml
      jnoortheen.nix-ide
      yzhang.markdown-all-in-one
      esbenp.prettier-vscode
      dbaeumer.vscode-eslint
    ];
    
    # User settings
    userSettings = {
      "editor.fontFamily" = "JetBrains Mono, Menlo, Monaco, 'Courier New', monospace";
      "editor.fontSize" = 14;
      "editor.lineHeight" = 22;
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.renderWhitespace" = "boundary";
      "editor.rulers" = [ 80 120 ];
      "files.trimTrailingWhitespace" = true;
      "terminal.integrated.fontFamily" = "JetBrains Mono";
      "terminal.integrated.fontSize" = 14;
      "workbench.colorTheme" = "Default Dark+";
    };
  };
  
  # Configure tmux
  programs.tmux = {
    enable = true;
    clock24 = true;
    historyLimit = 10000;
    mouse = true;
    
    extraConfig = ''
      # Set prefix key to C-a
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix
      
      # Use vim keybindings in copy mode
      setw -g mode-keys vi
      
      # Start window numbering at 1
      set -g base-index 1
      setw -g pane-base-index 1
      
      # Enable true color support
      set -g default-terminal "screen-256color"
      set-option -ga terminal-overrides ",*256col*:Tc"
    '';
  };
} 