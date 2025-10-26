{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;

      nixvimInjections = true;

      folding = true;
      settings = {
        indent.enable = true;
        highlight.enable = true;
        # ensure_installed = "all";
        auto_install = true;
      };
    };

    treesitter-refactor = {
      enable = true;
      settings = {
        highlight_definitions = {
          enable = true;
          # Set to false if you have an `updatetime` of ~100.
          clear_on_cursor_move = false;
        };
      };
    };

    hmts.enable = true;
  };
}
