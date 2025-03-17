# User-specific configuration
{
  config,
  inputs,
  pkgs,
  lib,
  home-manager,
  user,
  ...
}:
{
  imports = [
    ./settings/zsh.nix
    ./settings/dock.nix
  ];

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };
  
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "before-hm";
    verbose = true;
    users.${user} = { pkgs, config, lib, ... }: {
      home = {
        imports = [
          ./settings/packages.nix
          ./settings/programs.nix
        ];
        file.".inputrc".source = ./settings/inputrc;
        stateVersion = "24.11";
      };
    };
    extraSpecialArgs = {
      inherit inputs;
      inherit user;
    };
  };




}
