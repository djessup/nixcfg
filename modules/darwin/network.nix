{
  pkgs,
  lib,
  config,
  ...
}: {
  # Network settings
  # These will be overridden by host-specific settings in the host configuration
  networking = {
    # Default settings that can be overridden per-host
    computerName = "macOS";
    hostName = "darwin";
  };
} 