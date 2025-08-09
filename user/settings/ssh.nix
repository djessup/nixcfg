{ config, pkgs, lib, ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    compression = true;

    # SSH configuration for all hosts - Apple Keychain integration
    extraConfig = ''
Host *
  AddKeysToAgent yes
  UseKeychain yes

# ScaleFT/Okta Advanced Server Access configuration
Match exec "/usr/local/bin/sft resolve -q %h"
  ProxyCommand "/usr/local/bin/sft" proxycommand %h
  UserKnownHostsFile "/Users/jessup/Library/Application Support/ScaleFT/proxycommand_known_hosts"
    '';
  };

  # Create a launchd user agent to automatically load SSH keys from keychain at login
  launchd.agents.ssh-add-keychain = {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/ssh-add"
        "--apple-use-keychain"
        "/Users/jessup/.ssh/id_rsa-2025-07-18"
      ];
      RunAtLoad = true;
      KeepAlive = false;
      Label = "id.jessup.ssh-add-keychain";
    };
  };

  # Alternative approach: Use home activation script
  home.activation.loadSSHKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Load SSH key into Apple Keychain
    $DRY_RUN_CMD /usr/bin/ssh-add --apple-use-keychain /Users/jessup/.ssh/id_rsa-2025-07-18 2>/dev/null || true
  '';
}


