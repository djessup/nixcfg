# Secret management
{
  config,
  inputs,
  user,
  ...
}:
let
  # Path to the secrets repository
  secretsPath = builtins.toString inputs.nix-secrets;
in
{
  # SOPS configuration

  sops = {
    defaultSopsFile = "${secretsPath}/secrets.yaml";
    age = {
      keyFile = "${config.users.users.${user}.home}/.config/sops/age/keys.txt";
    };

    # mounts to: /run/secrets.d
    secrets = {
      nixAccessTokens = {
        mode = "0400";
        owner = config.users.users.${user}.name;
      };

      # GitHub self-hosted runner tokens
      # Format: github-runner-<username-or-org>-token (Must be added to secrets.yaml in nix-secrets)
      github-runner-jessup_adobe-token = {
        mode = "0400";
        owner = config.users.users.${user}.name;
      };
    };
  };
}