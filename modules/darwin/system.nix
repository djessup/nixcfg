{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  # System settings
  system = {
    # Auto upgrade nix package and daemon
    defaults = {
      # Finder settings
      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        _FXShowPosixPathInTitle = true;
        AppleShowAllFiles = true;
        FXRemoveOldTrashItems = true;
        NewWindowTarget = "Home";
        ShowStatusBar = true;
        ShowPathbar = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        QuitMenuItem = true;
      };
      
      # Dock settings
      dock = {
        autohide = true;
        show-recents = false;
        tilesize = 48;
        autohide-delay = 0.1;
        autohide-time-modifier = 0.5;
        orientation = "bottom";
      };
      
      # Other system defaults
      NSGlobalDomain = {
        AppleShowScrollBars = "Always";
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
      };
    };
    
    # System keyboard settings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    
    # Store Git commit hash for configuration tracking
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    # State version for backwards compatibility
    stateVersion = 5;
  };
  
  # Configure time zone and locale
  time.timeZone = "Australia/Sydney";
  
  # Enable fonts management
  fonts.fontDir.enable = true;
} 