{ pkgs, user, ... }:
{

  environment.systemPackages = [
    pkgs.devenv
  ];

  # Configure devenv to use zsh by default
  environment.variables = {
    # Ensure devenv uses zsh for shell environments
    DEVENV_SHELL = "${pkgs.zsh}/bin/zsh";

    # Point to user's shell initialization script
    DEVENV_SHELL_INIT = "/Users/${user}/.dev_shell_init";
  };

}
