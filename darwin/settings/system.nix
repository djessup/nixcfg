# macOS system settings configuration
{ pkgs, inputs, ... }: {

  system = {
    # Keyboard mappings
    # keyboard.enableKeyMapping = true;
    # keyboard.remapCapsLockToEscape = true;

    # macOS defaults (System Preferences)
    defaults = {  
      # Global domain settings (NSGlobalDomain)
      NSGlobalDomain = {
        # UI appearance settings
        # AppleInterfaceStyle = "Dark"; # Enable Dark Mode
        
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
        # autohide = true; # Automatically hide and show the Dock
        
        # Dock position and behavior
        orientation = "bottom"; # Place dock at the bottom of the screen
        show-recents = false;   # Don't show recently used applications
      };

      # Finder settings
      finder = {
        AppleShowAllExtensions = true;     # Show all file extensions in Finder
        _FXShowPosixPathInTitle = true;    # Show full POSIX path in window title
      };
    };
  };

  # Store Git commit hash for configuration tracking
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # State version for backwards compatibility
  # IMPORTANT: Do not change this unless you understand the implications
  # See: darwin-rebuild changelog
  system.stateVersion = 5;
}