# Homebrew configuration
{ config, pkgs, user, ... }:
{

   nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;

    # User owning the Homebrew prefix
    user = user;

    # Optional: Declarative tap management
    # taps = {
    #   "homebrew/homebrew-core" = homebrew-core;
    #   "homebrew/homebrew-cask" = homebrew-cask;
    #   "homebrew/homebrew-bundle" = homebrew-bundle;
    # };

    # Optional: Enable fully-declarative tap management
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = true;
  };

  # Let nix install packages via homebrew
  homebrew = {
    enable = true;

    # Use the Apple Silicon prefix for Homebrew
    brewPrefix = "/opt/homebrew/bin";

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
      extraFlags = [ "--verbose" ];
    };

    brews = [
      "amstool"
      "i2cssh"
      "jenv"
      "mvnvm"
      "nvm"
      "mas"
      # "arm-none-eabi-gcc"
      # "asdf"
      # "autoconf"
      # "automake"
      # "avr-gcc@9"
      # "avrdude"
      # "aws-sam-cli"
      # "awscli"
      # "azcopy"
      # "bash"
      # "bash-completion@2"
      # "btop"
      # "cmake"
      # "coreutils"
      # "cw"
      # "dfu-util"
      # "git"
      # "helm"
      # "jq"
      # "derailed/k9s/k9s"
      # "libssh"
      # "libssh2"
      # "libusb"
      # "libuv"
      # "llvm"
      # "localstack/tap/localstack-cli"
      # "lsusb"
      # "micromamba"
      # "minicom"
      # "ninja"
      # "open-ocd"
      # "openjdk@11"
      # "openssl@1.1"
      # "openssl@3"
      # "hashicorp/tap/packer"
      # "pkgconf"
      # "probe-rs/probe-rs/probe-rs"
      # "python@3.13"
      # "python@3.9"
      # "qemu"
      # "sdl2"
      # "skopeo"
      # "sonar-scanner"
      # "hudochenkov/sshpass/sshpass"
      # "tree"
      # "uv"
      # "watch"
      # "wget"
      # "yq"
      # "zsh"
      # "zsh-completions"
    ];

    casks = [
      "docker"
      "monitorcontrol" # Brightness and volume controls for external monitors.
      "unnaturalscrollwheels" # Enable natural scrolling in the trackpad but regular scroll on an external mouse
      "okta-advanced-server-access"
      # "gcc-arm-embedded"
      # "ghidra"
      # "iterm2"
      # "ngrok"
      # "visual-studio-code"
      # "warp"
      # "utm" # Virtual Machine Manager
    ];

    taps = [
      "armmbed/formulae"
      # "derailed/k9s"
      # "hashicorp/tap"
      "homebrew/bundle"
      "homebrew/services"
      "hudochenkov/sshpass"
      # "localstack/tap"
      # "lucagrulla/tap"
      "osx-cross/avr"
      # "probe-rs/probe-rs"
      "wouterdebie/repo"
      {
        name = "Pyramid/homebrew";
        clone_target = "git@git.corp.adobe.com:Pyramid/homebrew.git";
        force_auto_update = true;
      }
    ];

    whalebrews = [ ];

    # Install apps from the Mac App Store
    masApps = {
      reMarkable = 1276493162;
      "The Unarchiver" = 425424353;
      EtreCheck = 1423715984;
      Bitwarden = 1352778147;
      WhatsApp = 310633997;
      Xcode = 497799835;
      "Apple Configurator" = 1037126344;
      Enchanted = 6474268307;
    };
  };
}
