{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;

    colorschemes.catppuccin = {
      enable = true; 
      settings = {
        flavour = "mocha"; # latte, frappe, macchiato, mochatransparent_background
        transparent_background = true;
      };
    };

    plugins = {
      lualine.enable = true;

      # LSP
      lsp = {
        enable = true;
        servers = {
          pyright.enable = true;
        };
      };

      # Rustaceanvim - full-featured Rust support
      rustaceanvim = {
        enable = true;
        settings = {
          server.default_settings.rust-analyzer = {
            cargo.allFeatures = true;
            checkOnSave = true;
            check.command = "clippy";
            inlayHints = {
              closingBraceHints.enable = true;
              parameterHints.enable = true;
              typeHints.enable = true;
            };
            procMacro.enable = true;
          };
        };
      };

      # Completions
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
        settings.mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.close()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping.select_next_item()";
          "<S-Tab>" = "cmp.mapping.select_prev_item()";
        };
      };

      # Treesitter for better syntax highlighting
      treesitter = {
        enable = true;
        settings.ensure_installed = [ "rust" "python" "lua" "nix" "toml" ];
      };

      # File explorer
      neo-tree.enable = true;

      # Fuzzy finder
      telescope.enable = true;

      # Git integration
      gitsigns.enable = true;

      # Autopairs
      nvim-autopairs.enable = true;
    };

    # Keymaps for LSP
    keymaps = [
      { mode = "n"; key = "gd"; action = "<cmd>lua vim.lsp.buf.definition()<CR>"; options.desc = "Go to definition"; }
      { mode = "n"; key = "gr"; action = "<cmd>lua vim.lsp.buf.references()<CR>"; options.desc = "Go to references"; }
      { mode = "n"; key = "gi"; action = "<cmd>lua vim.lsp.buf.implementation()<CR>"; options.desc = "Go to implementation"; }
      { mode = "n"; key = "K"; action = "<cmd>lua vim.lsp.buf.hover()<CR>"; options.desc = "Hover documentation"; }
      { mode = "n"; key = "<leader>rn"; action = "<cmd>lua vim.lsp.buf.rename()<CR>"; options.desc = "Rename symbol"; }
      { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; options.desc = "Code action"; }
      { mode = "n"; key = "<leader>e"; action = "<cmd>lua vim.diagnostic.open_float()<CR>"; options.desc = "Show diagnostics"; }
      { mode = "n"; key = "[d"; action = "<cmd>lua vim.diagnostic.goto_prev()<CR>"; options.desc = "Previous diagnostic"; }
      { mode = "n"; key = "]d"; action = "<cmd>lua vim.diagnostic.goto_next()<CR>"; options.desc = "Next diagnostic"; }
      # Telescope
      { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<CR>"; options.desc = "Find files"; }
      { mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope live_grep<CR>"; options.desc = "Live grep"; }
      { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<CR>"; options.desc = "Buffers"; }
      # Neo-tree
      { mode = "n"; key = "<leader>n"; action = "<cmd>Neotree toggle<CR>"; options.desc = "Toggle file tree"; }
    ];

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      signcolumn = "yes";
      termguicolors = true;
      cursorline = true;
    };

    # Diagnostic display settings
    diagnostic.settings = {
      virtual_text = true;
      signs = true;
      underline = true;
      update_in_insert = false;
      severity_sort = true;
    };
  };
}
