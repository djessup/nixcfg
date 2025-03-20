{
  pkgs,
  lib,
  config,
  inputs,
  user,
  ...
}: {
  imports = [
    # Import all Darwin-specific modules here
    ./system.nix
    ./homebrew.nix
    ./nix.nix
    ./security.nix
    ./network.nix
    ./environment.nix
    ./dock
  ];
  
  # SOPS configuration
  sops = lib.mkIf (inputs ? nix-secrets) {
    defaultSopsFile = "${builtins.toString inputs.nix-secrets}/secrets.yaml";
    age = {
      keyFile = "${config.users.users.${user}.home}/.config/sops/age/keys.txt";
    };
    secrets.nixAccessTokens = {
      mode = "0400";
      owner = config.users.users.${user}.name;
    };
  };
  
  # Host platform configuration
  nixpkgs.hostPlatform = "aarch64-darwin"; # Target Apple Silicon architecture
} 