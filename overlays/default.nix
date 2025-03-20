{
  inputs,
  ...
}: {
  flake.overlays = {
    # Define the default overlay
    default = final: prev: {
      # Add any custom packages or overrides here
    };
    
    # Add NUR overlay
    nur = inputs.nur.overlay;
  };
} 