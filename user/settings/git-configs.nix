# Conditional Git configurations for different email addresses
# These files are referenced by includeIf directives in git.nix
{ config, user, ... }:
let
  homeDir = "/Users/${user}";
in
{
  # Create conditional Git config files for different contexts
  home.file = {
    # Personal repositories configuration
    ".config/git/config-personal".text = ''
      [user]
        email = 866649+djessup@users.noreply.github.com
        name = David Jessup
        signingkey = ${homeDir}/.ssh/id_ed25519_djessup_signing.pub
    '';

    # Work repositories configuration
    ".config/git/config-work".text = ''
      [user]
        email = jessup@adobe.com
        name = David Jessup
        signingkey = ${homeDir}/.ssh/id_ed25519_adobe_signing.pub
    '';
  };
}

