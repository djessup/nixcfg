{ config, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    compression = true;
#
#    extraConfig = "";
#    extraOptionOverrides = { };

  };

}

/*
Host *
  AddKeysToAgent yes
  UseKeychain yes

ssh-add --apple-use-keychain ~/.ssh/id_rsa-2025-01-06

{
  programs.ssh = {
    enable = true;
    # SSH configuration for all hosts:
    config = ''
      Host *
        AddKeysToAgent yes
        UseKeychain yes
    '';
    agent = {
      enable = true;
      keys = [
        "~/.ssh/id_rsa"
        "~/.ssh/another_key"
      ];
    };
  };
}
---OR---
{
  programs.ssh = {
    enable = true;
    config = ''
      Host *
        AddKeysToAgent yes
        UseKeychain yes
    '';
    # Optionally, you can enable the agent without specifying keys.
    agent.enable = true;
  };
}
*/