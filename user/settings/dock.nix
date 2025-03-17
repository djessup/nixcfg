{ config, pkgs, home-manager, user, ... }:
{
  imports = [
    ./dock
  ];
  # Fully declarative dock using the latest from Nix Store
  local.dock = {
    enable = true;
    entries = [
      { path = "${pkgs.iterm2}/Applications/iTerm.app/"; }
      { path = "${pkgs.warp-terminal}/Applications/Warp.app/"; }
      { path = "${pkgs.code-cursor}/Applications/Cursor.app/"; }
      { path = "/Applications/Microsoft Teams.app/"; }
      { path = "/Applications/Slack.app/"; }
      { path = "/Applications/Outlook.app/"; }
      { path = "/Applications/Microsoft Edge.app/"; }
      { path = "/Applications/System Settings.app/"; }
      { path = "/Applications/Github Desktop.app/"; }
      { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
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
        options = "--sort name --view grid --display stack";
      }
    ];
  };
}