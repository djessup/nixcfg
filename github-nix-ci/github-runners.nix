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
    # Enable the service
    enable = true;

    # Personal repositories
    # Add your personal repositories here with the number of runners you want
    personalRunners = {
      # Example configuration:
       "djessup/speakr".num = 1;
       "jessup_adobe/vscode-dispatcher-syntax".num = 2;
    };

    # Organization repositories
    # Add organizations here - runners will be available to all repos in the org
    orgRunners = {
      # Example configuration:
       "jessup_adobe".num = 3;
    };

    # Token configuration using SOPS secrets
    # The tokens will be automatically picked up from SOPS secrets
    # based on the naming convention: github-runner-<name>-token
    # where <name> is the username or organization name

    # Additional runner configuration
    settings = {
      # Set runner labels (optional)
      # labels = [ "nix" "darwin" "self-hosted" ];

      # Runner working directory (optional)
      # workDir = "/tmp/github-runner";

      # Replace existing runners on startup (optional)
      # replace = true;
    };
  };
}
