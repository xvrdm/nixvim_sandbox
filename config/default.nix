{ self
, pkgs
, ...
}: {
  # Import all your configuration modules here
  imports = [
    ./bufferline.nix
  ];
  colorschemes.gruvbox.enable = true;

  #extraPython3Packages = p: with p; [ jupyter-client pynvim cairosvg pnglatex plotly pyperclip ];

  extraPlugins = [
    { plugin = pkgs.vimPlugins.quarto-nvim; }
    { plugin = pkgs.vimPlugins.otter-nvim; }
    {
      plugin = pkgs.vimUtils.buildVimPlugin {
        name = "jupytext-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "GCBallesteros";
          repo = "jupytext.nvim";
          rev = "68fddf28119dbaddfaea6b71f3d6aa1e081afb93";
          sha256 = "x5emW+qfUTUDR72B9QdDgVdrb8wGH9D7AdtRrQm80sI=";
        };
      };
    }
  ];

  extraConfigLua = ''
    	vim.g.maplocalleader = ";"
    	require("jupytext").setup({
    			style = "markdown",
    			output_extension = "md",
    			force_ft = "markdown",
    			})

    require("quarto").setup({
    		lspFeatures = {
    		-- NOTE: put whatever languages you want here:
    		languages = { "r", "python", "rust" },
    		chunks = "all",
    		diagnostics = {
    		enabled = true,
    		triggers = { "BufWritePost" },
    		},
    		completion = {
    		enabled = true,
    		},
    		},
    		keymap = {
    		-- NOTE: setup your own keymaps:
    		hover = "H",
    		definition = "gd",
    		rename = "<leader>rn",
    		references = "gr",
    		format = "<leader>gf",
    		},
    		codeRunner = {
    			enabled = true,
    			default_method = "molten",
    		},
    })

    local runner = require("quarto.runner")
    	vim.keymap.set("n", "<localleader>ec", runner.run_cell,  { desc = "run cell", silent = true })
    	vim.keymap.set("n", "<localleader>ea", runner.run_above, { desc = "run cell and above", silent = true })
    	vim.keymap.set("n", "<localleader>eA", runner.run_all,   { desc = "run all cells", silent = true })
    	vim.keymap.set("n", "<localleader>el", runner.run_line,  { desc = "run line", silent = true })
    	vim.keymap.set("v", "<localleader>e",  runner.run_range, { desc = "run visual range", silent = true })
    	vim.keymap.set("n", "<localleader>RA", function()
    			runner.run_all(true)
    			end, { desc = "run all cells of all languages", silent = true })

    	local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
    	local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand

    	-- Remove whitespace on save
    	autocmd('BufWritePre', {
    			pattern = "",
    			command = ":%s/\\s\\+$//e"
    			})

    autocmd('BufEnter', {
    		pattern = { 'md' },
    		command = 'require("quarto").activate()'
    		})


    -- Set indentation to 2 spaces
    	augroup('setIndent', { clear = true })
    	autocmd('Filetype', {
    			group = 'setIndent',
    			pattern = { 'xml', 'html', 'xhtml', 'css', 'scss', 'javascript', 'typescript', 'nix',
    			'yaml', 'lua'
    			},
    			command = 'setlocal shiftwidth=2 tabstop=2'
    			})
  '';
  plugins = {
    lualine.enable = true;
  };

  globals.mapleader = " ";

  plugins.lsp = {
    enable = true;
    servers = {
      tsserver.enable = true;
      lua-ls.enable = true;
      rnix-lsp.enable = true;
      pyright.enable = true;
      #r_language_server.enable = true;
    };
  };

  plugins.molten = {
   enable = true;
  package = pkgs.vimUtils.buildVimPlugin {
      pname = "molten-nvim";
      version = "2024-02-23";
      src = pkgs.fetchFromGitHub {
        owner = "benlubas";
        repo = "molten-nvim";
        rev = "8346bba69e0de96278dad2038e9be74605908b7d";
        # sha256 = lib.fakeSha256;
        sha256 = "08f3zxzka43f87fks56594476h57yq01x7a1zdsn4acc278xg1nb";
      };
      passthru.python3Dependencies = ps:
        with ps; [
          pynvim
          jupyter-client
          cairosvg
          ipython
          nbformat
        ];
      meta.homepage = "https://github.com/benlubas/molten-nvim/";
    };
  };

  plugins.luasnip = {
    enable = true;
  };

  plugins.cmp_luasnip = {
    enable = true;
  };

  plugins.cmp-nvim-lsp = {
    enable = true;
  };

  plugins.nvim-cmp = {
    enable = true;
    autoEnableSources = true;
    sources = [
      { name = "nvim_lsp"; }
      { name = "path"; }
      { name = "buffer"; }
      { name = "luasnip"; }
    ];

    mapping = {
      "<CR>" = "cmp.mapping.confirm({ select = true })";
      "<Tab>" = {
        action = ''
          function(fallback)
            local luasnip = require 'luasnip'
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expandable() then
              luasnip.expand()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end
        '';
        modes = [ "i" "s" ];
      };
    };
  };
}
