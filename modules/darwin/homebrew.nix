{
  pkgs,
  lib,
  config,
  inputs,
  user,
  ...
}: {
  # Configure Homebrew
  homebrew = {
    enable = true;
    # Use the Apple Silicon prefix for Homebrew
    brewPrefix = "/opt/homebrew/bin";
    
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall"; # Uninstall formulae not listed below
      upgrade = true;
      extraFlags = [ "--verbose" ];
    };
    
    taps = [
      "homebrew/core"
      "homebrew/cask"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/bundle"
      "homebrew/services"
      "armmbed/formulae"
      "hudochenkov/sshpass"
      "osx-cross/avr"
      "wouterdebie/repo"
      {
        name = "Pyramid/homebrew";
        clone_target = "git@git.corp.adobe.com:Pyramid/homebrew.git";
        force_auto_update = true;
      }
    ];
    
    # CLI applications that aren't available through Nix
    brews = [
      "amstool"
      "i2cssh"
      "jenv"
      "mvnvm"
      "nvm"
      "mas" # Mac App Store CLI
      "moreutils"
    ];
    
    # macOS applications
    casks = [
      "1password"
      "alfred"
      "brave-browser"
      "discord"
      "docker"
      "firefox"
      "google-chrome"
      "slack"
      "visual-studio-code"
      "zoom"
      "obsidian"
      "monitorcontrol" # Brightness and volume controls for external monitors
      "unnaturalscrollwheels" # Enable natural scrolling in the trackpad but regular scroll on an external mouse
      "okta-advanced-server-access"
    ];
    
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
  
  # Configure Homebrew-specific user settings
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = user;
    # Use the external inputs for homebrew repositories
    mutableTaps = true;
    autoMigrate = true;
  };
} 