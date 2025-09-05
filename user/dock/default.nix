{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.local.dock;
  inherit (pkgs) stdenv dockutil;
in
{
  options = {
    local.dock = {
      # Option to enable/disable dock management
      enable = mkOption {
        description = "Enable dock";
        default     = stdenv.isDarwin; # Enabled by default on macOS
      };

      entries = mkOption {
        description = "Entries on the Dock";
        type =
          with types;
          listOf (submodule {
            options = {
              path    = lib.mkOption {
                type = str;
                default = "";
                description = "Path to the application or file";
              };
              section = lib.mkOption {
                type    = str;
                default = "apps";
                description = "Dock section (apps or others)";
              };
              options = lib.mkOption {
                type    = str;
                default = "";
                description = "Additional dockutil options";
              };
              type = lib.mkOption {
                type = str;
                default = "";
                description = "Type of dock item (spacer, small-spacer, flex-spacer, or empty for regular items)";
              };
            };
          });
        readOnly = true;
      };


    };
  };

  config = mkIf cfg.enable (
    let
      # Ensure app paths end with a trailing slash
      normalize = path: if hasSuffix ".app" path then path + "/" else path;

      # Convert paths to properly encoded file:// URIs
      entryURI =
        path:
        "file://"
        + (builtins.replaceStrings
          [ " " "!" "\"" "#" "$" "%" "&" "'" "(" ")" ]
          [ "%20" "%21" "%22" "%23" "%24" "%25" "%26" "%27" "%28" "%29" ]
          (normalize path)
        );

        # Check if an entry is a spacer type
        isSpacerType = type: type == "spacer" || type == "small-spacer" || type == "flex-spacer";

        # Generate a more comprehensive comparison string that includes section and options
        # This improves idempotence by detecting changes to section or options
        wantEntries = concatMapStrings (
          entry:
          if isSpacerType entry.type then
            "SPACER|${entry.type}|${entry.section}\n"
          else
            "${entryURI entry.path}|${entry.section}|${entry.options}\n"
        ) cfg.entries;

        # Generate commands to create all dock entries
        createEntries = concatMapStrings (
          entry:
          if isSpacerType entry.type then
            "${dockutil}/bin/dockutil --no-restart --add '' --type ${entry.type} --section ${entry.section}\n"
          else
            "${dockutil}/bin/dockutil --no-restart --add '${entry.path}' --section ${entry.section} ${entry.options}\n"
        ) cfg.entries;

        # Generate the dock setup script with interpolated variables
        setupDockScript = pkgs.replaceVars ./setup-dock.sh.template {
          wantEntries = wantEntries;
          createEntries = createEntries;
          dockutil = dockutil;
          gawk = pkgs.gawk;
          coreutils = pkgs.coreutils;
        };
    in
    {
      # Run during user activation via home-manager
      home.activation.setupDock = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        echo >&2 "Setting up the Dock..."
        ${builtins.readFile setupDockScript}
      '';
    }
  );
}
