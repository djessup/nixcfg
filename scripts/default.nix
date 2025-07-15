{ pkgs, ... }:

let
  # Create the nix-cleanup script as a derivation
  nix-cleanup = pkgs.writeShellScriptBin "nix-cleanup" (builtins.readFile ./nix-cleanup.sh);
in
{
  # Export the script for use in systemPackages
  inherit nix-cleanup;
}
