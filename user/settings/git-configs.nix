# Conditional Git configurations for different email addresses
# These files are referenced by includeIf directives in git.nix
{ user, ... }:
let
  githubProfiles = import ./git-profiles.nix { inherit user; };
  githubProfileList = builtins.attrValues githubProfiles;

  # Render a per-profile Git include file containing identity and signing settings.
  mkProfileConfig = profile: ''
    [user]
      email = ${profile.userEmail}
      name = ${profile.userName}
      signingkey = ${profile.signingKey}
      identityFile = "${profile.identityFile}";
  '';
in
{
  # Materialize one include file per profile under ~/.config/git/.
  home.file =
    builtins.listToAttrs (map (profile: {
      name = ".config/git/${profile.configName}";
      value.text = mkProfileConfig profile;
    }) githubProfileList);
}

