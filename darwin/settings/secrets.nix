# Secret management
{
  config,
  inputs,
  user,
  ...
}:
let
  # Path to the secrets repository
  secretsPath = toString inputs.nix-secrets;
in
{
  # SOPS configuration

  sops = {
    defaultSopsFile = "${secretsPath}/secrets.yaml";
    age = {
      keyFile = "${config.users.users.${user}.home}/.config/sops/age/keys.txt";
    };

    # mounts to: `/run/secrets.d`
    secrets = {
      # Nix access tokens (e.g., GitHub)
      nixAccessTokens = {
        mode = "0400";
        owner = config.users.users.${user}.name;
      };

      # jessup-use2-codex Azure OAI credentials
      azure-openai-api-key = {
        mode = "0400";
        owner = config.users.users.${user}.name;
      };

      # GitHub self-hosted runner tokens
      # Format: github-runner-<username-or-org>-token (Must be added to secrets.yaml in nix-secrets)
      github-runner-djessup-token = {
        mode = "0400";
        owner = config.users.users.${user}.name;
      };
      github-runner-jessup_adobe-token = {
        mode = "0400";
        owner = config.users.users.${user}.name;
      };
      # Artifactory Corp credentials
      artifactory-corp-user = {
        mode = "0400";
        owner = config.users.users.${user}.name;
      };
      artifactory-corp-token = {
        mode = "0400";
        owner = config.users.users.${user}.name;
      };
    };

  };
}
