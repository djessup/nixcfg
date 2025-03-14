# System-wide configuration
{ config, pkgs, inputs, home-manager, ... }: {

  # User mappings, the rest is handled by home-manager
  users.users.jessup = {
    home = /Users/jessup;
    shell = pkgs.zsh;
  };

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # Disable press and hold diacritics
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  # Allow commerical software packages to be installed
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # https://gist.github.com/kamilmodest/7884e22fccaed05f1049d41d04b2685a for ideas
  ];

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };

  security.pam.services.sudo_local = {
    # Enable biometric auth for sudo
    touchIdAuth = true;
    watchIdAuth = true;
    # This allows programs like tmux and screen that run in the background to survive across user sessions to work with PAM services that are tied to the bootstrap session.
    reattach = true;
  };

  # Let nix install packages via homebrew 
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };

    brews = [
      "pyramid/homebrew/amstool"
      # "arm-none-eabi-gcc"
      "asdf"
      "autoconf"
      "automake"
      "avr-gcc@9"
      "avrdude"
      "aws-sam-cli"
      "awscli"
      "azcopy"
      "bash"
      "bash-completion@2"
      "btop"
      "cmake"
      "coreutils"
      "cw"
      "dfu-util"
      "git"
      "helm"
      "i2cssh"
      "jenv"
      "jq"
      "derailed/k9s/k9s"
      "libssh"
      "libssh2"
      "libusb"
      "libuv"
      "llvm"
      "localstack/tap/localstack-cli"
      "lsusb"
      "micromamba"
      "minicom"
      "mvnvm"
      "ninja"
      "nvm"
      "open-ocd"
      "openjdk@11"
      "openssl@1.1"
      "openssl@3"
      "hashicorp/tap/packer"
      "pkgconf"
      "probe-rs/probe-rs/probe-rs"
      "python@3.13"
      "python@3.9"
      "qemu"
      "sdl2"
      "skopeo"
      "sonar-scanner"
      "hudochenkov/sshpass/sshpass"
      "tree"
      "uv"
      "watch"
      "wget"
      "yq"
      "zsh"
      "zsh-completions"
    ];

    casks = [
      "gcc-arm-embedded"
      "ghidra"
      "iterm2"
      "ngrok"
      "visual-studio-code"
      "warp"
      "docker"
      "monitorcontrol" # Brightness and volume controls for external monitors.
      "unnaturalscrollwheels" # Enable natural scrolling in the trackpad but regular scroll on an external mouse
      "utm" # Virtual Machine Manager
    ];

    taps = [
      "armmbed/formulae"
      "derailed/k9s"
      "hashicorp/tap"
      "homebrew/bundle"
      "homebrew/services"
      "hudochenkov/sshpass"
      "localstack/tap"
      "lucagrulla/tap"
      "osx-cross/avr"
      "probe-rs/probe-rs"
      "wouterdebie/repo"
      {
        name = "Pyramid/homebrew";
        clone_target = "git@git.corp.adobe.com:Pyramid/homebrew.git";
        force_auto_update = true;
      }
    ];

    whalebrews = [];

    # Install apps from the Mac App Store
    masApps = { 
      reMarkable            = 1276493162;
      "The Unarchiver"      = 425424353;
      EtreCheck             = 1423715984;
      Bitwarden             = 1352778147;
      WhatsApp              = 310633997;
      Xcode                 = 497799835;
      "Apple Configurator"  = 1037126344;
      Enchanted             = 6474268307;
    };
  };

}
