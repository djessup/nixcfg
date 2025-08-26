# GitHub self-hosted runners configuration
{
  config,
  inputs,
  user,
  ...
}:
let
  # Path to the secrets repository
  secretspath = builtins.toString inputs.nix-secrets;
in
{
  # Self-hosted GitHub runners using github-nix-ci
  services.github-nix-ci = {
    # We use SOPS for secrets; disable agenix scaffolding in this module
    age.secretsDir = null;

    # Personal repositories
    # Add your personal repositories here with the number of runners you want
    personalRunners = {
      # Example configuration with explicit SOPS token file paths
      "djessup/speakr" = {
        num = 1;
        tokenFile = config.sops.secrets."github-runner-djessup-token".path;
      };
      "jessup_adobe/vscode-dispatcher-syntax" = {
        num = 1;
        tokenFile = config.sops.secrets."github-runner-jessup_adobe-token".path;
      };
    };

    # Organization repositories
    # Add organizations here - runners will be available to all repos in the org
    orgRunners = {
      # Example configuration with explicit SOPS token file path
      "jessup_adobe" = {
        num = 2;
        tokenFile = config.sops.secrets."github-runner-jessup_adobe-token".path;
      };
    };

    # Token configuration using SOPS secrets
    # The tokens will be automatically picked up from SOPS secrets
    # based on the naming convention: github-runner-<name>-token
    # where <name> is the username or organization name

    # Additional runner configuration can be provided via runnerSettings if needed, e.g.:
    # runnerSettings.extraPackages = [ ];
  };
}
