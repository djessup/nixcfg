{ pkgs, ... }: 
{
  fonts.packages = with pkgs; [
#    font-jetbrains-mono # JetBrains Mono font with programming ligatures
#    font-source-code-pro # Source Code Pro font
#    font-iosevka-ss14 # Iosevka SS14 font with programming ligatures
#    font-hack-nerd-font # Hack Nerd Font with programming ligatures and icons
#    font-cascadia-code # Cascadia Code font with programming ligatures
#    font-ubuntu-mono-nerd-font # Ubuntu Mono Nerd Font with programming ligatures and icons

    # Programming fonts
    nerd-fonts.fira-code # Fira Code font with programming ligatures
    font-awesome # Icon font
    
    hack-font # Programmer font
    meslo-lgs-nf # Powerline font
    monaspace # Monaspace https://monaspace.githubnext.com/
    nerd-fonts.monaspace # Monaspace font with icons
    nerd-fonts.jetbrains-mono # Developer font with icons
    noto-fonts # Google font family
    noto-fonts-color-emoji # Emoji font
  ];
}
