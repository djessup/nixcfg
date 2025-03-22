{ ... }:
{
  security = {
    pam.services.sudo_local = {
      # Enable biometric auth for sudo
      touchIdAuth = true;
      watchIdAuth = true;
      # This allows programs like tmux and screen that run in the background to survive across user sessions to work with PAM services that are tied to the bootstrap session.
      reattach = true;
    };
  };
}
