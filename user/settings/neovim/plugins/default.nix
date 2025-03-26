{ pkgs, ... }:
{
  imports = [
    # ./barbar.nix
    ./comment.nix
    ./dap.nix
    ./gitblame.nix
    # ./harpoon.nix
    ./indent-o-matic.nix
    ./lazygit.nix
    ./lint.nix
    ./lsp.nix
    ./lualine.nix
    ./markdown-preview.nix
    ./mini.nix
    ./neoscroll.nix
    ./nix.nix
    ./noice.nix
    ./oil.nix
    # ./tagbar.nix
    ./telescope.nix
    ./tree-sitter.nix
    ./trouble.nix
    ./which-key.nix
    ./web-devicons.nix
  ];

  # Neovim
  programs.nixvim = {

    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    luaLoader.enable = true;

    colorschemes = {
      nightfox = {
        enable = true;
      };
      monokai-pro = {
        enable = false;
      };
      onedark = {
        enable = false;
      };
      gruvbox = {
        enable = false;
        settings = {
          transparent_mode = false;
        };
      };
      catppuccin = {
        enable = false;
        settings = {
          flavour = "mocha";
          integrations = {
            cmp = true;
            gitsigns = true;
            nvimtree = true;
            treesitter = true;
            notify = false;
          };
        };
      };
      kanagawa = {
        enable = false;
        settings = {
          colors = {
            palette = {
              fujiWhite = "#FFFFFF";
              sumiInk0 = "#000000";
            };
            theme = {
              all = {
                ui = {
                  bg_gutter = "none";
                };
              };
              dragon = {
                syn = {
                  parameter = "yellow";
                };
              };
              wave = {
                ui = {
                  float = {
                    bg = "none";
                  };
                };
              };
            };
          };
          commentStyle = {
            italic = true;
          };
          compile = false;
          dimInactive = false;
          functionStyle = { };
          overrides = "function(colors) return {} end";
          terminalColors = true;
          theme = "wave";
          transparent = false;
          undercurl = true;
        };
      };
    };


    # performance.byteCompileLua.enable = true;

    plugins = {

      # nvim-tree.enable = true;
      # diffview.enable = true;
      # gitsigns.enable = true;
      # gitlinker.enable = true;
      # presence-nvim.enable = true;
      # copilot-vim.enable = true;

      gitsigns = {
        enable = true;
        settings.signs = {
          add.text = "+";
          change.text = "~";
        };
      };

      transparent.enable = true;
      nvim-autopairs.enable = true;
      none-ls.enable = true;
      nvim-surround.enable = true;

      trim = {
        enable = true;
        settings = {
          highlight = false;
          ft_blocklist = [
            "checkhealth"
            "floaterm"
            "lspinfo"
            "TelescopePrompt"
          ];
        };
      };
    };
  };
}
