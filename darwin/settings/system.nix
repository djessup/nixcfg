{ pkgs, inputs, ... }: {

  system = {
    # keyboard.enableKeyMapping = true;
    # keyboard.remapCapsLockToEscape = true;

    defaults = {  
      NSGlobalDomain = {
        # Dark mode
        # AppleInterfaceStyle = "Dark";
        
        # Show all file extensions
        AppleShowAllExtensions = true;
        # Disable press and hold diacritics
        ApplePressAndHoldEnabled = false;

        # Automatically hide and show the menu bar
        # _HIHideMenuBar = true;
      };

      dock = {
        # Automatically hide and show the Dock
        # autohide = true;
        
        # Style options
        orientation = "left";
        show-recents = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };
    };
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}