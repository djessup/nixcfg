{
  pkgs,
  lib,
  config,
  ...
}: {
  # Environment settings
  environment = {
    shells = with pkgs; [
      bash
      zsh
    ];
    systemPackages = with pkgs; [ 
      coreutils      
    ];
    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" "/share/zsh" ];
    
    # Variables to set in /etc/zshrc (system-wide environment variables)
    variables = {
      EDITOR = "vim";
      VISUAL = "cursor";
    };
  };
} 