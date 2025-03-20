{
  inputs,
  lib,
  ...
}: {
  imports = [
    # Import specific host configurations here
    ./jessup-mbp
  ];

  flake = {
    # This allows other modules to access the host definitions
    hostModules = {
      jessup-mbp = ./jessup-mbp;
    };
  };
} 