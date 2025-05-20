# { config, lib, pkgs, ... }:
# # TODO: Move to user home-manager activation script
# let
#   # The Linux builder script, wrapped in Nix
#   builderScript = pkgs.writeShellScript "start-linux-builder" ''
#     exec ${pkgs.nix}/bin/nix run nixpkgs#darwin.linux-builder --no-write-lock-file \
#       >> /var/log/linux-builder.log 2>&1
#   '';

#   targetPath = "/opt/nix-linux-builder/start.sh";
# in {
#   # Install the script with strict permissions
#   environment.etc."nix-linux-builder".source = builderScript;

#   # This places the script where we want and locks it down at activation
#   system.activationScripts.secureLinuxBuilder.text = ''
#     echo "Installing secured linux-builder script..."

#     install -d -o root -g wheel -m 755 /opt/nix-linux-builder
#     install -o root -g wheel -m 700 ${builderScript} ${targetPath}

#     # Optional hardening (comment out if not needed)
#     chflags schg ${targetPath}
#   '';

#   # Optional: sudo rule scoped to this path
#   environment.etc."sudoers.d/linux-builder".text = ''
#     Defaults:${config.users.users.${config.primaryUser}.name} !requiretty
#     ${config.users.users.${config.primaryUser}.name} ALL=(root) NOPASSWD: ${targetPath}
#   '';
# }