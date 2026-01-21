{
  config,
  inputs,
  pkgs,
  user,
  ...
}:
let
  homeDir = "/Users/${user}";
  githubRunnerSvc = "actions.runner.jessup.${user}";
  # SSH signing key paths (user-managed, not in Nix store)
  # Default to work key since most repos are work-related
  defaultSigningKeyPath = "${homeDir}/.ssh/id_ed25519_adobe_signing";
  personalSigningKeyPath = "${homeDir}/.ssh/id_ed25519_djessup_signing";
in
{

  # Git config
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "David Jessup";
    userEmail = "jessup@adobe.com";

    # Commit signing configuration using SSH keys (default to work key)
    signing = {
      key = "${defaultSigningKeyPath}.pub";
      signByDefault = true;
    };

    extraConfig = {
      init.defaultBranch = "master";
      credential."https://git.cloudmanager.adobe.com".provider = "generic";

      # Rewrite HTTPS GitHub URLs to use SSH
      url."ssh://git@github.com/".insteadOf = "https://github.com/";

      # Configure Git to use SSH for signing instead of GPG
      gpg.format = "ssh";

      # Optional: Configure allowed signers file for local verification
      # This allows you to verify commits locally without GitHub
      gpg.ssh.allowedSignersFile = "${homeDir}/.ssh/allowed_signers";

      pager = {
        diff = false;
        show = false;
        blame = false;
      };

      # Conditional includes for different email addresses based on directory
      # Personal repos use personal config, everything else uses work config (default)
      includeIf."gitdir:~/Documents/Github/personal/".path = "${homeDir}/.config/git/config-personal";
    };
  };

  services.github-runner = {

  };

  # Github Self-hosted runner
#  launchd.agents.github-runner = {
#    enable = true;
#    config = {
#      ProgramArguments = [
#        "${pkgs.github-runner}/runsvc.sh"
#      ];
#      RunAtLoad = true;
#      Label = "${githubRunnerSvc}";
#      UserName = user;
#      WorkingDirectory = "";
#      StandardOutPath = "${homeDir}/Library/Logs/${githubRunnerSvc}/stdout.log";
#      StandardErrorPath = "${homeDir}/Library/Logs/${githubRunnerSvc}/stderr.log";
#      EnvironmentVariables = {
#        ACTIONS_RUNNER_SVC = "1";
#      };
#      ProcessType = "Interactive";
#      SessionCreate = true;
#    };
#  };
}
