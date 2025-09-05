{ pkgs, ... }:
{
  # Provide selected tools from Lix's package set. Avoid nix-direnv due to recursion issues.
  nixpkgs.overlays = [ (final: prev: {
    inherit (final.lixPackageSets.stable)
      nixpkgs-review
      nix-eval-jobs
      nix-fast-build
      colmena;
  }) ];

  # Use Lix as the system's nix
  nix.package = pkgs.lixPackageSets.stable.lix;
}
