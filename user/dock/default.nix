{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  # Configuration shorthand
  cfg = config.local.dock;
  inherit (pkgs) stdenv dockutil;
in
{
  options = {
    # Option to enable/disable dock management
    local.dock.enable = mkOption {
      description = "Enable dock";
      default = stdenv.isDarwin; # Enabled by default on macOS
      example = false;
    };

    # Define the structure for dock entries
    local.dock.entries = mkOption {
      type =
        with types;
        listOf (submodule {
          options = {
            path = lib.mkOption {
              type = str;
              description = "Path to application or folder to add to the Dock";
              example = "/Applications/Safari.app";
              default = "";
            };
            section = lib.mkOption {
              type = str;
              default = "apps"; # Default section is apps
              description = "Section to add the item to (apps, others, or recent)";
              example = "others";
            };
            options = lib.mkOption {
              type = str;
              default = ""; # Additional dockutil options
              description = "Additional options to pass to dockutil";
              example = "--display folder --sort name";
            };
            type = lib.mkOption {
              type = str;
              default = "";
              description = "Type of dock item, use 'spacer', 'small-spacer', or 'flex-spacer' for adding spaces";
              example = "small-spacer";
            };
          };
        });
      default = [ ];
      example = [
        { path = "/Applications/Safari.app"; }
        { type = "small-spacer"; }
        { path = "/Applications/Mail.app"; }
        { type = "flex-spacer"; }
        { path = "/Applications/Calendar.app"; }
        {
          path = "~/Downloads";
          section = "others";
          options = "--display folder --sort name";
        }
      ];
      description = ''
        List of items to place in the macOS Dock.

        Items will appear in the order specified. Applications go in the apps section by default,
        while folders and files can be placed in the "others" section.
        
        You can use spacers to visually organize your dock by setting type to one of:
        - "spacer": Regular-sized spacer
        - "small-spacer": Small-sized spacer
        - "flex-spacer": Flexible spacer that expands to fill available space

        Example:
          local.dock.entries = [
            { path = "/Applications/Safari.app"; }
            { path = "/Applications/Mail.app"; }
            { type = "small-spacer"; }
            { path = "~/Downloads"; section = "others"; options = "--display folder"; }
            { type = "flex-spacer"; }
          ];
      '';
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
          [
            " "
            "!"
            "\""
            "#"
            "$"
            "%"
            "&"
            "'"
            "("
            ")"
          ]
          [
            "%20"
            "%21"
            "%22"
            "%23"
            "%24"
            "%25"
            "%26"
            "%27"
            "%28"
            "%29"
          ]
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
    in
    {
      # Run during system activation
      system.activationScripts.postUserActivation.text = ''
        echo >&2 "Setting up the Dock..."

        # Create a function to get current dock items with their sections
        get_current_dock_entries() {
          ${dockutil}/bin/dockutil --list | while read -r line; do
            # Check if this is a spacer
            if echo "$line" | grep -q "spacer"; then
              spacer_type=$(echo "$line" | ${pkgs.gawk}/bin/awk '{print $3}')
              section=$(echo "$line" | ${pkgs.gawk}/bin/awk '{print $NF}' | tr -d '()')
              echo "SPACER|$spacer_type|$section"
            else
              uri=$(echo "$line" | ${pkgs.coreutils}/bin/cut -f2)
              section=$(echo "$line" | ${pkgs.gawk}/bin/awk '{print $NF}' | tr -d '()')
              options=""
              echo "$uri|$section|$options"
            fi
          done
        }

        # Get current dock entries in a comparable format
        haveEntries="$(get_current_dock_entries)"

        # Compare current dock state with desired state (ignoring whitespace differences)
        if ! diff -wB <(echo -n "$haveEntries") <(echo -n '${wantEntries}') >/dev/null ; then
          echo >&2 "Dock configuration has changed. Updating..."
          # Remove all existing items
          ${dockutil}/bin/dockutil --no-restart --remove all
          # Add each configured entry in order
          ${createEntries}
          # Restart the Dock to apply changes
          killall Dock
        else
          echo >&2 "Dock setup complete."
        fi
      '';
    }
  );
}
