{ pkgs, ... }:
{
  environment = {
    shells = with pkgs; [
      bash
      zsh
    ];
    systemPackages = [ pkgs.coreutils ];
    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];
  };
}

# List packages installed in system profile. To search by name, run:
# $ nix-env -qaP | grep wget
# environment.systemPackages = with pkgs; [
#   # https://gist.github.com/kamilmodest/7884e22fccaed05f1049d41d04b2685a for ideas
#   raycast
#   iterm2
#   jetbrains.writerside
#   jetbrains.clion
#   jetbrains.idea-ultimate
#   jetbrains.rust-rover
#   utm
#   warp-terminal
#   code-cursor
#   vscode
#   fzf
# ];

# Link zsh completions to /share/zsh
# environment.pathsToLink = [ "/share/zsh" ];
