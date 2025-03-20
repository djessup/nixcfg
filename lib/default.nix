{
  pkgs,
  lib,
  ...
}: rec {
  # Helper function to import all Nix files in a directory except default.nix
  importDir = dir:
    let
      contents = builtins.readDir dir;
      isNixFile = name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix";
      nixFiles = lib.filterAttrs isNixFile contents;
      importFile = name: _: import (dir + "/${name}");
    in
    lib.mapAttrs importFile nixFiles;
  
  # Helper to create a home-manager config with consistent settings
  mkHomeConfig = { username, system, extraModules ? [] }:
    { pkgs, lib, ... }: {
      imports = extraModules;
      
      home = {
        inherit username;
        homeDirectory = "/Users/${username}";
        stateVersion = "23.11";
      };
      
      programs.home-manager.enable = true;
    };
} 