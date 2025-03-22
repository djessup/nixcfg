{ inputs, pkgs, lib, nixvim, ... }: {
  imports = [
    # nixvim.homeManagerModules.nixvim
    ./autocommands.nix
    ./completion.nix
    ./keymappings.nix
    ./options.nix
    ./plugins
    ./todo.nix
  ];
  /**
  programs.nixvim = {



    plugins = {

      
      lualine = {
        enable = true;
        settings = {
          extensions = ["nvim-tree" "fzf" "fugitive"];
          options = {
            icons_enabled = false;
            globalstatus = true;
            disabled_filetypes.statusline = ["DiffviewFiles" "fzf" "DiffviewFileHistory"];
            section_separators = {
              left = "";
              right = "";
            };
          };
          sections = {
            lualine_a = ["mode"];
            lualine_b = [];
            lualine_c = [
              "filename"
              {
                color = {
                  bg = "#16161D";
                };
              }
            ];
            lualine_x = [
              "filetype"
              {
                color = {
                  bg = "#16161D";
                };
              }
            ];
            lualine_y = ["diff" "branch"];
          };
        };
      };

      lsp = {
        enable = true;

        servers = {
          ts_ls.enable = true;
          gopls.enable = true;
          elixirls.enable = true;
          clojure_lsp.enable = true;
          nixd.enable = true;

          lua_ls = {
            enable = true;
            settings.telemetry.enable = false;
          };
        };

        keymaps = {
          silent = true;
          lspBuf = {
            K = "hover";
            gd = "definition";
            gD = "declaration";
            gi = "implementation";
          };
        };
      };
    };

    keymaps = [
      {
        action = "<cmd>Telescope live_grep<CR>";
        key = "<leader>fg";
      }
      {
        action = "<cmd>Telescope find_files<CR>";
        key = "<C-p>";
      }
      {
        action = "<cmd>NvimTreeFindfile<CR>";
        key = "<c-n>";
      }
      {
        action = "<cmd>NvimTreeToggle<CR>";
        key = "<leader>n";
      }
    ];
    
    autoCmd = [
      # Vertically center document when entering insert mode
      {
        event = "InsertEnter";
        command = "norm zz";
      }

      # Open help in a vertical split
      {
        event = "FileType";
        pattern = "help";
        command = "wincmd L";
      }

      # Enable spellcheck for some filetypes
      {
        event = "FileType";
        pattern = [
          "markdown"
        ];
        command = "setlocal spell spelllang=en";
      }
    ];
    
    extraPlugins = with pkgs.vimPlugins; [
      {
        plugin = vim-dispatch;
      }
      {
        plugin = vim-jack-in;
      }
      {
        plugin = vim-dispatch-neovim;
      }
      {
        plugin = plenary-nvim;
      }
      {
        plugin = mason-nvim;
        config = "lua require('mason').setup()";
      }
      {
        plugin = mason-lspconfig-nvim;
        config = "lua require('mason-lspconfig').setup()";
      }
    ];

    opts = {
      expandtab = true;
      number = true;
      relativenumber = true;
      clipboard = "unnamedplus";
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
    };

    globals.mapleader = " ";
    globals.maplocalleader = ",";
    
  }; */
}
