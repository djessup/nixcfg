{ user }:
let
  homeDir = "/Users/${user}";
in
{
  # Personal GitHub identity and matching rules.
  personal = {
    alias = "github-personal";
    configName = "config-personal";
    configPath = "${homeDir}/.config/git/config-personal";
    gitDir = "~/Documents/Github/personal/";
    owners = [
      "djessup"
      "adobe"
    ];

    userName = "David Jessup";
    userEmail = "866649+djessup@users.noreply.github.com";
    signingKey = "${homeDir}/.ssh/id_ed25519_djessup_signing.pub";
    identityFile = "${homeDir}/.ssh/id_rsa-djessup-gh";
  };

  # Work GitHub identity and matching rules.
  work = {
    alias = "github-work";
    configName = "config-work";
    configPath = "${homeDir}/.config/git/config-work";
    gitDir = "~/Documents/GitHub/ams-inno/";
    owners = [
      "jessup_adobe"
      "AdobeManagedServices"
      "AdobeManagedServices-Innovation"
      "OneAdobe"
    ];

    userName = "David Jessup";
    userEmail = "jessup@adobe.com";
    signingKey = "${homeDir}/.ssh/id_ed25519_adobe_signing.pub";
    identityFile = "${homeDir}/.ssh/id_rsa";
  };
}
