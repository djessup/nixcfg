{
  inputs,
  pkgs,
  lib,
  ...
}: {
  # For now, import the existing neovim configuration
  # This should be migrated in the future to use the new modular structure
  imports = [
    ../../../user/settings/neovim
  ];
  
  # Enable nixvim
  programs.nixvim = {
    enable = true;
  };
} 