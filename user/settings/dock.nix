{ config, user, pkgs, inputs, ... }: {
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
      { path = "/Applications/Visual Studio Code.app/"; }
      { path = "/Applications/Github Desktop.app/"; }
      # { path = "${pkgs.jetbrains.idea}/Applications/IntelliJ IDEA.app/"; }
      { type = "spacer"; }

      # Productivity
      { path = "/Applications/GitHub Copilot.app/"; }
      { path = "/Applications/ChatGPT.app/"; }
      { path = "/Applications/Claude.app/"; }
      { type = "spacer"; }
      { path = "${pkgs.pkgsStable.obsidian}/Applications/Obsidian.app/"; }
      { path = "/Applications/Microsoft To Do.app/"; }
      { type = "spacer"; }

      # Communication
      { path = "/Applications/Microsoft Edge.app/"; }
      { path = "${pkgs.slack}/Applications/Slack.app/"; }
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
