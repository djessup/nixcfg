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
in
{

  # Git config
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "David Jessup";
    userEmail = "jessup@adobe.com";
    extraConfig = {
      init.defaultBranch = "master";
      credential."https://git.cloudmanager.adobe.com".provider = "generic";
      pager = {
        diff = false;
        show = false;
        blame = false;
      };
    };
  };

  services.github-runner = {
    globgul = {
      enable = true;
      name = "globgul_runner";
      tokenFile = "${config.sops.secrets.github-runner-jessup_adobe-token.path}";
      url = "https://github.com/jessup_adobe/globgul-mcp";
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