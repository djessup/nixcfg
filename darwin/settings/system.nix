# macOS system settings configuration
{ inputs, ... }: {

  system = {
    # Keyboard mappings
    # keyboard.enableKeyMapping = true;
    # keyboard.remapCapsLockToEscape = true;

    # macOS defaults (System Preferences)
    defaults = {
      # Global domain settings (NSGlobalDomain)
      NSGlobalDomain = {
        # UI appearance settings
        AppleInterfaceStyle = "Dark"; # Enable Dark Mode

        # File extension visibility
        AppleShowAllExtensions = true; # Show all file extensions in Finder

        # Keyboard settings
        ApplePressAndHoldEnabled = false; # Disable press-and-hold for keys in favor of key repeat

        # Menu bar visibility
        # _HIHideMenuBar = true; # Auto-hide menu bar
      };

      # Dock settings
      dock = {
        # Visibility settings
        autohide = true;                # Automatically hide and show the Dock
        autohide-delay = 0.025;           # Dock autohide delay in seconds (default: 0.24)
        autohide-time-modifier = 0.3;   # Dock autohide animation duration  (default: 1.0)
        # Dock position and behavior
        orientation = "bottom"; # Place dock at the bottom of the screen
        show-recents = false;   # Don't show recently used applications
      };

      # Finder settings
      finder = {
        AppleShowAllFiles = true;           # Show hidden files in Finder
        AppleShowAllExtensions = true;      # Show all file extensions in Finder
        FXRemoveOldTrashItems = true;       # Remove items from the Trash after 30 days
        NewWindowTarget = "Home";           # Open new Finder windows in the home directory
        ShowStatusBar = true;               # Show status bar at the bottom of Finder windows
        ShowPathbar = true;                 # Show path breadcrumbs in finder windows
        ShowHardDrivesOnDesktop = true;     # Show hard drives on the desktop
        ShowMountedServersOnDesktop = true; # Show connected servers on the desktop
        _FXShowPosixPathInTitle = false;    # Show full POSIX path in window title
        QuitMenuItem = true;                # Show Quit Finder in Finder menu
      };

    };

    # source: https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
    activationScripts.postUserActivation.text = ''
      # Activate system settings immediately after user activation, without requiring a reboot
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
  };

  # Store Git commit hash for configuration tracking
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # State version for backwards compatibility
  # IMPORTANT: Do not change this unless you understand the implications
  # See: darwin-rebuild changelog
  system.stateVersion = 5;
}