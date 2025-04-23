# Homebrew configuration
{ user, ... }:
{
   # Use nix-homebrew to manage the homebrew installation
   nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;

    # User owning the Homebrew prefix
    user = user;

    # Enable if there is an existing non-Nix Homebrew installation we want to import
    # autoMigrate = true;

    # Optional: Enable fully-declarative tap management
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = true;
    # # Optional: Declarative tap management
    # taps = { };
  };

  # Let nix-darwin install Homebrew packages (brews), taps, casks, and Mac App Store (mas) apps.
  homebrew = {
    enable = true;

    # Use the Apple Silicon prefix for Homebrew instead of the Intel one
    brewPrefix = "/opt/homebrew/bin";

    onActivation = {
      # autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
      extraFlags = [ "--verbose" ];
    };

    # !! – Where possible, prefer nixpkgs packages over homebrew for better portability. - !!
    brews = [
      "amstool"
      "i2cssh"
      "jenv"
      "mvnvm"
      "nvm"
      "mas"
    ];

    casks = [
      "docker" # Docker Desktop
      "ghidra"
      "monitorcontrol" # Brightness and volume controls for external monitors.
      "nordic-nrf-command-line-tools"
      "nrf-connect"
      "nrfutil"
      "okta-advanced-server-access"
      "keyguard"
      "unnaturalscrollwheels" # Enable natural scrolling in the trackpad but regular scroll on an external mouse
      "ubar" # Dock replacement
      "xquartz" # X11 server
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
      Bitwarden = 1352778147;
      WhatsApp = 310633997;
      Xcode = 497799835;
      "Apple Configurator" = 1037126344;
      Enchanted = 6474268307;
      DaisyDisk = 411643860;
    };
  };
}
