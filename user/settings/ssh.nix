{ config, pkgs, lib, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        compression = true;
        extraOptions = {
          UseKeychain = "yes";
        };
      };

      "github-work" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_rsa";
        identitiesOnly = true;
      };

      "github-personal" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_rsa-djessup-gh";
        identitiesOnly = true;
      };
    };

    # Additional SSH configuration
    extraConfig = ''
# ScaleFT/Okta Advanced Server Access configuration
Match exec "/usr/local/bin/sft resolve -q %h"
  ProxyCommand "/usr/local/bin/sft" proxycommand %h
  UserKnownHostsFile "~/Library/Application Support/ScaleFT/proxycommand_known_hosts"
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
        "/Users/jessup/.ssh/id_rsa-2025-10-16"
        "/Users/jessup/.ssh/id_ed25519_signing"  # Add signing key
      ];
      RunAtLoad = true;
      KeepAlive = false;
      Label = "id.jessup.ssh-add-keychain";
    };
  };

  # Alternative approach: Use home activation script
  home.activation.loadSSHKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Load SSH keys into Apple Keychain
    $DRY_RUN_CMD /usr/bin/ssh-add --apple-use-keychain /Users/jessup/.ssh/id_rsa-2025-07-18 2>/dev/null || true
    $DRY_RUN_CMD /usr/bin/ssh-add --apple-use-keychain /Users/jessup/.ssh/id_ed25519_signing 2>/dev/null || true
  '';
}


