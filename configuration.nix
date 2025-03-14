# System-wide configuration
{
  config,
  pkgs,
  inputs,
  home-manager,
  ...
}:
{

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
    raycast
    iterm2
    jetbrains.writerside
    jetbrains.clion
    jetbrains.idea-ultimate
    jetbrains.rust-rover
    utm
    warp-terminal
    code-cursor
    vscode
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

  # Import homebrew configuration
  imports = [ ./homebrew.nix ];
}
