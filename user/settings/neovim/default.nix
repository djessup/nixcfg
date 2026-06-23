{ inputs, pkgs, lib, nixvim, ... }: {
  imports = [
    # nixvim.homeManagerModules.nixvim
    ./autocommands.nix
    ./completion.nix
    # ./keymappings.nix
    ./options.nix
    ./plugins
    ./todo.nix
  ];
}
