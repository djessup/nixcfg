{ pkgs, ... }:
{
  environment = {
    shells = with pkgs; [
      bash
      zsh
    ];
    systemPackages = with pkgs; [
      coreutils
    ];
    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];
  };
}

# TODO: Figure out if this has any value or remove
# Link zsh completions to /share/zsh
# environment.pathsToLink = [ "/share/zsh" ];
