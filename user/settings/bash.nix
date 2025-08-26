{ ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;

    # Common aliases (mirrors zsh where applicable)
    shellAliases = {
      nixbuild = "darwin-rebuild build --flake /etc/nix-darwin/.# --show-trace -L -v |& nom";
      nixswitch = "sudo darwin-rebuild switch --flake /etc/nix-darwin/.# --show-trace -L -v |& nom";
      nixfluff = "nix flake --log-format internal-json -v update |& nom --json";
      nixup = "pushd /etc/nix-darwin; nixfluff; nixswitch; popd";
      nombuild = "nom build /etc/nix-darwin/.#darwinConfigurations.jessup-m3.config.system.build.toplevel";

      g = "git";
      gs = "git status -sb";
      gd = "git diff";
      gl = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";

      ".." = "cd ..";
      "..." = "cd ../..";
      ls = "eza --icons";
      ll = "eza -lah --icons --git";
      tree = "eza --tree --icons";
      watch = "hwatch";

      cursor = "/Applications/Cursor.app/Contents/MacOS/Cursor";
      python = "python3";
      "docker-clean" = "docker rmi $(docker images -f 'dangling=true' -q)";
      tfgo = "terraform plan -out tfplan && terraform apply tfplan";
    };

    # Extra bashrc content
    initExtra = ''
      # Initialize direnv for bash
      if command -v direnv >/dev/null 2>&1; then
        eval "$(direnv hook bash)"
      fi
    '';
  };
}
