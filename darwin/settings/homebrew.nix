# Homebrew configuration
{ inputs, config, pkgs, user, ... }:
{

   nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;

    # User owning the Homebrew prefix
    user = user;

    # autoMigrate = true;

    # # Optional: Declarative tap management
    # taps = {
    #   "homebrew/homebrew-core" = inputs.homebrew-core;
    #   "homebrew/homebrew-cask" = inputs.homebrew-cask;
    #   "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
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
      # autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
      extraFlags = [ "--verbose" ];
    };

    brews = [
      "amstool"
      "i2cssh"
      "jenv"
      "mvnvm"
      "nvm"
      "mas"
    ];

    casks = [
      "docker"
      "monitorcontrol" # Brightness and volume controls for external monitors.
      "unnaturalscrollwheels" # Enable natural scrolling in the trackpad but regular scroll on an external mouse
      "okta-advanced-server-access"
      # "ghidra"
    ];

    taps = [
      "hudochenkov/sshpass"
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
