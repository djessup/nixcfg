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
  # workSigningKeyPath = defaultSigningKeyPath;
  personalSigningKeyPath = "${homeDir}/.ssh/id_ed25519_djessup_signing";
in
{

  # Git config (see; https://nix-community.github.io/home-manager/options.xhtml#opt-programs.git.enable)
  programs.git = {
    enable = true;
    lfs.enable = true;

    # Commit signing configuration using SSH keys (default to work key)
    signing = {
      key = "${defaultSigningKeyPath}.pub";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "David Jessup";
        email = "jessup@adobe.com";
      };

      init.defaultBranch = "main";
      
      credential."https://git.cloudmanager.adobe.com".provider = "generic";

      # Rewrite GitHub URLs to use the github-personal/github-work SSH host aliases,
      # which maps to the personal/work SSH keys in ~/.ssh/config.
      # Longest-match wins, so these override the generic rule above.
      url."git@github-personal:djessup/".insteadOf = [ 
        "git@github.com:djessup/" 
        "https://github.com/djessup/" 
      ];
      url."git@github-work:jessup_adobe/".insteadOf = [ 
        "git@github.com:jessup_adobe/" 
        "https://github.com/jessup_adobe/" 
      ];
      url."git@github-work:AdobeManagedServices/".insteadOf = [
        "git@github.com:AdobeManagedServices/"
        "https://github.com/AdobeManagedServices/"
      ];
      url."git@github-work:OneAdobe/".insteadOf = [
        "git@github.com:OneAdobe/"
        "https://github.com/OneAdobe/"
      ];      
      url."git@github-work:AdobeManagedServices-Innovation/".insteadOf = [
        "git@github.com:AdobeManagedServices-Innovation/"
        "https://github.com/AdobeManagedServices-Innovation/"
      ];

      # Configure Git to use SSH for signing instead of GPG
      gpg.format = "ssh";

      # Optional: Configure allowed signers file for local verification
      # This allows you to verify commits locally without GitHub
      gpg.ssh.allowedSignersFile = "${homeDir}/.ssh/allowed_signers";

      # Disable git pagers
      pager = {
        diff = false;
        show = false;
        blame = false;
      };

      # Conditional includes for different email addresses based on directory
      # Personal repos use personal config, everything else uses work config (default)
      includeIf."gitdir:~/Documents/Github/personal/".path = "${homeDir}/.config/git/config-personal";
      # Personal remotes
      includeIf."hasconfig:remote.*.url:git@github.com:djessup/**".path = "${homeDir}/.config/git/config-personal";
      includeIf."hasconfig:remote.*.url:git@github-personal:djessup/**".path = "${homeDir}/.config/git/config-personal";
      includeIf."hasconfig:remote.*.url:https://github.com/djessup/**".path = "${homeDir}/.config/git/config-personal";

      # Work remotes
      includeIf."hasconfig:remote.*.url:git@github.com:jessup_adobe/**".path = "${homeDir}/.config/git/config-work";
      includeIf."hasconfig:remote.*.url:git@github.com:AdobeManagedServices/**".path = "${homeDir}/.config/git/config-work";
      includeIf."hasconfig:remote.*.url:git@github.com:OneAdobe/**".path = "${homeDir}/.config/git/config-work";
    };
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
