# System-wide configuration
{
  config,
  pkgs,
  inputs,
  home-manager,
  user,
  ...
}:
{
  nix = {
    # Necessary for using flakes on this system.
    settings.experimental-features = "nix-command flakes";
    # Optimise the Nix store automatically
    optimise.automatic = true;
    # Garbage collect the Nix store automatically
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };

  # Host architecture for the system the configuration is being used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  # Allow commerical software packages to be installed
  nixpkgs.config.allowUnfree = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh = {
    enable = true;
    # enableCompletion = true;
    # enableBashCompletion = true;
    # enableLsColors = true;
    # enableFzfCompletion = true;
    # enableFzfGit = true;
    # enableFzfHistory = true;
  };

  # Enable bash completion
  programs.bash.completion.enable = true;

  # Enable man pages
  programs.man.enable = true;

  # Enable nix-index
  programs.nix-index.enable = true;

  # # User mappings, the rest is handled by home-manager
  # users.users."${user}" = {
  #   home = "/Users/${user}";
  #   shell = pkgs.zsh;
  # };

  # Import settings
  imports = [ 
    ./settings/system.nix
    ./settings/environment.nix
    ./settings/security.nix
    ./settings/network.nix
    ./settings/homebrew.nix 
  ];
}
