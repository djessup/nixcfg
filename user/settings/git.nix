{
  user,
  ...
}:
let
  homeDir = "/Users/${user}";
  # Shared profile data is the single source of truth for owners, aliases, and identities.
  githubProfiles = import ./git-profiles.nix { inherit user; };
  githubProfileList = builtins.attrValues githubProfiles;

  # Rewrite GitHub clone URLs to SSH host aliases that select the right SSH key.
  mkGithubUrlRewrite = alias: owner: {
    name = "git@${alias}:${owner}/";
    value.insteadOf = [
      "git@github.com:${owner}/"
      "https://github.com/${owner}/"
    ];
  };

  # Match remotes and attach the correct conditional Git include file.
  mkGithubIncludeIfs = {
    owner,
    configPath,
    sshHosts ? [ "github.com" ],
    includeHttps ? true,
  }:
    builtins.listToAttrs (
      (builtins.concatMap (host: [
        {
          name = "hasconfig:remote.*.url:git@${host}:${owner}/**";
          value.path = configPath;
        }
      ]) sshHosts)
      ++ (if includeHttps then [
        {
          name = "hasconfig:remote.*.url:https://github.com/${owner}/**";
          value.path = configPath;
        }
      ] else [ ])
    );

  # Build the includeIf attrset for a list of GitHub owners.
  mkGithubIncludeIfSet = {
    owners,
    configPath,
    sshHosts ? [ "github.com" ],
    includeHttps ? true,
  }:
    builtins.foldl' (acc: owner:
      acc // mkGithubIncludeIfs {
        inherit owner configPath sshHosts includeHttps;
      }
    ) { } owners;

  # Generate all URL rewrite entries for one profile.
  mkGithubProfileUrlSettings = profile:
    builtins.listToAttrs (map (mkGithubUrlRewrite profile.alias) profile.owners);

  # Generate all includeIf rules for one profile, including optional local path matching.
  mkGithubProfileIncludeIfSettings = profile:
    (if profile ? gitDir then {
      "gitdir:${profile.gitDir}".path = profile.configPath;
    } else { })
    // mkGithubIncludeIfSet {
      owners = profile.owners;
      configPath = profile.configPath;
      sshHosts = [ "github.com" profile.alias ];
    }
    // mkGithubIncludeIfSet {
      owners = profile.httpsOnlyOwners;
      configPath = profile.configPath;
      sshHosts = [ ];
    };

  # Merge all profile URL rewrites into a single Git `url` block.
  githubUrlSettings =
    builtins.foldl' (acc: profile:
      acc // mkGithubProfileUrlSettings profile
    ) { } githubProfileList;

  # Merge all profile include rules into a single Git `includeIf` block.
  githubIncludeIfSettings =
    builtins.foldl' (acc: profile:
      acc // mkGithubProfileIncludeIfSettings profile
    ) { } githubProfileList;
in
{

  # Git config (see; https://nix-community.github.io/home-manager/options.xhtml#opt-programs.git.enable)
  programs.git = {
    enable = true;
    lfs.enable = true;

    # Commit signing configuration using SSH keys (default to work key)
    signing = {
      key = githubProfiles.work.signingKey;
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
      url = githubUrlSettings;

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

      # Select the right per-profile Git identity based on repo path or remote URL.
      includeIf = githubIncludeIfSettings;
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
#      Label = "actions.runner.jessup.${user}";
#      UserName = user;
#      WorkingDirectory = "";
#      StandardOutPath = "${homeDir}/Library/Logs/actions.runner.jessup.${user}/stdout.log";
#      StandardErrorPath = "${homeDir}/Library/Logs/actions.runner.jessup.${user}/stderr.log";
#      EnvironmentVariables = {
#        ACTIONS_RUNNER_SVC = "1";
#      };
#      ProcessType = "Interactive";
#      SessionCreate = true;
#    };
#  };
}
