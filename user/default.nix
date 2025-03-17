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
    ./dock
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
      imports = [
        ./settings/programs.nix
        ./settings/zsh.nix
      ];
      home = {
        packages = (import ./settings/packages.nix { inherit pkgs; }).packages;
        file.".inputrc".source = ./settings/inputrc;
        stateVersion = "24.11";
      };
    };
    extraSpecialArgs = {
      inherit inputs;
      inherit user;
    };
  };

  local.dock = {
    enable = true;
    entries = [
      { path = "${pkgs.iterm2}/Applications/iTerm2.app/"; }
      { path = "${pkgs.warp-terminal}/Applications/Warp.app/"; }
      { path = "${pkgs.code-cursor}/Applications/Cursor.app/"; }
      { path = "/Applications/Microsoft Teams.app/"; }
      { path = "/Applications/Slack.app/"; }
      { path = "/Applications/Microsoft Outlook.app/"; }
      { path = "/Applications/Microsoft Edge.app/"; }
      { path = "/System/Applications/System Settings.app/"; }
      { path = "/Applications/Github Desktop.app/"; }
      { path = "/System/Applications/Podcasts.app/"; }
      { path = "/Applications/ChatGPT.app/"; }

      { path = "${pkgs.jetbrains.idea-ultimate}/Applications/IntelliJ IDEA.app/"; }
      { path = "${pkgs.jetbrains.clion}/Applications/CLion.app/"; }
      { path = "${pkgs.jetbrains.rust-rover}/Applications/RustRover.app/"; }
      {
        path = "/Applications";
        section = "others";
        options = "--sort name --view grid --display folder";
      }
      {
        path = "${config.users.users.${user}.home}/Downloads";
        section = "others";
        options = "--sort name --view fan --display stack";
      }
    ];
  };
}
