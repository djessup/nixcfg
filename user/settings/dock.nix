{ config, user, pkgs, ... }: {
  # Dock configuration using custom module
  local.dock = {
    enable = true;
    entries = [
      # System applications
      # (Finder appears first, by default)
      { path = "/System/Applications/System Settings.app/"; }
      { type = "spacer"; }

      # Terminal applications
      { path = "${pkgs.iterm2}/Applications/iTerm2.app/"; }
      { type = "spacer"; }

      # Development IDEs
      { path = "/Applications/Cursor.app/"; }
      { path = "${pkgs.jetbrains.idea}/Applications/IntelliJ IDEA.app/"; }
      { path = "${pkgs.jetbrains.pycharm}/Applications/PyCharm.app/"; }
      { path = "${pkgs.jetbrains.rust-rover}/Applications/RustRover.app/"; }
      { path = "/Applications/Github Desktop.app/"; }
      { type = "spacer"; }

      # Productivity applications
      { path = "/Applications/ChatGPT.app/"; }
      { path = "${pkgs.obsidian}/Applications/Obsidian.app/"; }
      { type = "spacer"; }

      # Communication applications
      { path = "/Applications/Microsoft Teams.app/"; }
      { path = "/Applications/Slack.app/"; }
      { path = "/Applications/Microsoft Outlook.app/"; }
      { path = "/Applications/Microsoft Edge.app/"; }
      { type = "spacer"; }

      # Media
      { path = "/System/Applications/Podcasts.app/"; }
      { type = "spacer"; }

      # Folders
      {
        path = "/Applications";
        section = "others";
        options = "--sort name --view grid --display folder";
      }
      {
        path = "${config.home.homeDirectory}/Downloads";
        section = "others";
        options = "--sort dateadded --view fan --display stack";
      }
    ];
  };
}
