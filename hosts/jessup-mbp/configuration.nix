{
  pkgs,
  lib,
  inputs,
  user,
  config,
  ...
}: {
  # Host-specific settings
  networking.hostName = "jessup-mbp";
  networking.computerName = "Jessup's MacBook Pro";
  
  # Dock configuration
  local.dock = {
    enable = true;
    entries = [
      # System applications
      # (Finder appears first, by default)
      { path = "/System/Applications/System Settings.app/"; }
      { type = "spacer"; }

      # Terminal applications
      { path = "${pkgs.iterm2}/Applications/iTerm2.app/"; }
      { path = "${pkgs.warp-terminal}/Applications/Warp.app/"; }
      { type = "spacer"; }
      
      # Development IDEs
      { path = "${pkgs.code-cursor}/Applications/Cursor.app/"; }
      { path = "${pkgs.jetbrains.idea-ultimate}/Applications/IntelliJ IDEA.app/"; }
      { path = "${pkgs.jetbrains.clion}/Applications/CLion.app/"; }
      { path = "${pkgs.jetbrains.rust-rover}/Applications/RustRover.app/"; }
      { path = "/Applications/Github Desktop.app/"; }
      { type = "spacer"; }

      # Communication applications
      { path = "/Applications/Microsoft Teams.app/"; }
      { path = "/Applications/Slack.app/"; }
      { path = "/Applications/Microsoft Outlook.app/"; }
      { path = "/Applications/Microsoft Edge.app/"; }
      { type = "spacer"; }

      # Productivity applications
      { path = "/Applications/ChatGPT.app/"; }
      { path = "/Applications/Notes.app/"; }
      { path = "/System/Applications/Podcasts.app/"; }
      { type = "spacer"; }
      
      # Folders
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
  
  # Import existing darwin and user settings
  # This will be removed once we migrate all settings to the modular structure
  imports = [
    ../../darwin
    ../../user
  ];
} 