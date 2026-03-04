{ config, user, pkgs, ... }: {
  # Dock configuration using custom module
  local.dock = {
    enable = true;
    entries = [
      # System applications
      # (Finder appears first, by default)
      { path = "/System/Applications/System Settings.app/"; }
      { type = "spacer"; }

      # Terminal
      { path = "${pkgs.iterm2}/Applications/iTerm2.app/"; }
      { type = "spacer"; }

      # Development
      { path = "/Applications/Cursor.app/"; }
      { path = "/Applications/Github Desktop.app/"; }
      { path = "/Applications/Codex.app/"; }
      { path = "${pkgs.jetbrains.idea}/Applications/IntelliJ IDEA.app/"; }
      { type = "spacer"; }

      # Productivity
      { path = "/Applications/ChatGPT.app/"; }
      { path = "${pkgs.obsidian}/Applications/Obsidian.app/"; }
      { type = "spacer"; }

      # Communication
      { path = "/Applications/Microsoft Edge.app/"; }
      { path = "/Applications/Slack.app/"; }
      { path = "/Applications/Microsoft Teams.app/"; }
      { path = "/Applications/Microsoft Outlook.app/"; }
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
