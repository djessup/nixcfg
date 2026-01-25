{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;

      nixvimInjections = true;

      folding.enable = true;
      settings = {
        indent.enable = true;
        highlight.enable = true;
        # ensure_installed = "all";
        auto_install = true;
      };
    };
  };
}
