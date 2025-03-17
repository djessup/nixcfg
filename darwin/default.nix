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
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;

  # The platform the configuration will be used on.
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

  programs.bash.completion.enable = true;

  programs.man.enable = true;
  programs.nix-index.enable = true;

  # User mappings, the rest is handled by home-manager
  users.users."${user}" = {
    home = "/Users/${user}";
    shell = pkgs.zsh;
  };

  # Import settings
  imports = [ 
    ./settings/system.nix
    ./settings/environment.nix
    ./settings/security.nix
    ./settings/network.nix
    ./settings/homebrew.nix 
    ./settings/dock.nix
  ];
}
