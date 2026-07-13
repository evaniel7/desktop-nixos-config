# NixOS module that installs this Neovim config for every user on the system.
#
# Plugins are pinned to the exact revisions recorded in ./nvim-pack-lock.json
# (the lockfile vim.pack itself maintains - see `:help vim.pack-lockfile`) and
# fetched by Nix at evaluation time, so `nvim` never needs network access or
# writes into the Nix store at runtime.
#
# Mason is intentionally not used: LSP servers/formatters come from nixpkgs
# instead (see `lspPackages` below) and are put on PATH. init.lua was edited
# to drop mason.nvim/mason-lspconfig.nvim/mason-tool-installer.nvim and call
# vim.lsp.enable() directly.
#
# This directory is a nix-oriented copy of the parent ../ config (which stays
# on Mason/vim.pack as-is for everyday interactive use). Usage from a
# flakes-based system config, either:
#   imports = [ /home/evaniel/.config/nvim/nixos-nvim/nvim.nix ];
# or add this directory as a flake input and:
#   imports = [ "${inputs.nvim-config}/nixos-nvim/nvim.nix" ];
# (see the sibling flake.nix, which exposes this as `nixosModules.default`)
#
# Caveats:
#   - Requires nixpkgs' `neovim` to be >=0.12 (needed for vim.pack itself).
#   - Do not run `:lua vim.pack.update()` under this setup: the plugin
#     directories are read-only Nix store paths. To bump a plugin, update it
#     normally in the parent ../ config (or a scratch checkout) outside of
#     Nix, let vim.pack rewrite nvim-pack-lock.json, then copy that file (and
#     any init.lua changes) back here and rebuild.
#   - nvim-treesitter still compiles parsers into ~/.local/share/nvim on first
#     use of a filetype (that directory is untouched by this module), so it
#     still needs network + a C compiler + tree-sitter-cli the first time -
#     both of which are included in systemPackages below.
#   - LuaSnip's optional `jsregexp` native build is skipped (its Makefile
#     fetches a luarocks package over the network, which a sandboxed Nix
#     build can't do); this only disables some regex-trigger snippet
#     features, LuaSnip itself works fine without it.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  lock = builtins.fromJSON (builtins.readFile ./nvim-pack-lock.json);

  # These are replaced by nixpkgs packages (see lspPackages) instead.
  droppedPlugins = [
    "mason.nvim"
    "mason-lspconfig.nvim"
    "mason-tool-installer.nvim"
  ];

  wantedPlugins = lib.filterAttrs (name: _: !(builtins.elem name droppedPlugins)) lock.plugins;

  fetchPlugin = spec: builtins.fetchGit {
    url = spec.src;
    rev = spec.rev;
  };

  # telescope-fzf-native.nvim ships a native matcher that vim.pack normally
  # compiles via a `make` build step the first time it installs the plugin
  # (see the PackChanged autocmd in init.lua). Since we hand vim.pack an
  # already-populated, read-only plugin directory, that hook never fires,
  # so build it here instead.
  telescopeFzfNative = pkgs.stdenv.mkDerivation {
    pname = "telescope-fzf-native.nvim";
    version = wantedPlugins."telescope-fzf-native.nvim".rev;
    src = fetchPlugin wantedPlugins."telescope-fzf-native.nvim";
    nativeBuildInputs = [ pkgs.gnumake ];
    dontConfigure = true;
    buildPhase = "make";
    installPhase = ''
      mkdir -p $out
      cp -r . $out
    '';
  };

  pluginDerivations = lib.mapAttrs (
    name: spec: if name == "telescope-fzf-native.nvim" then telescopeFzfNative else fetchPlugin spec
  ) wantedPlugins;

  # Assembles $XDG_DATA_HOME/nvim/site/pack/core/opt: one symlink per plugin,
  # named exactly as vim.pack expects (see `:help vim.pack-directory`).
  packOpt = pkgs.linkFarm "nvim-pack-core-opt" (
    lib.mapAttrsToList (name: drv: {
      inherit name;
      path = drv;
    }) pluginDerivations
  );

  nvimConfig = pkgs.runCommand "nvim-config" { } ''
    mkdir -p $out
    cp -r ${./lua} $out/lua
    cp -r ${./doc} $out/doc
    cp ${./init.lua} $out/init.lua
  '';

  lspPackages = with pkgs; [
    clang-tools # clangd
    pyright
    rust-analyzer
    tinymist
    lua-language-server
    stylua
  ];
in
{
  environment.systemPackages =
    with pkgs;
    [
      neovim
      git
      ripgrep
      fd
      gnumake
      gcc
      tree-sitter
    ]
    ++ lspPackages;

  # Deploys the config + pinned plugins into every user's home the moment
  # they log in. init.lua/lua/doc and the plugin directory are symlinked
  # read-only into the Nix store; nvim-pack-lock.json is copied once (and
  # left writable) so vim.pack's own bookkeeping has somewhere to write
  # without touching the store.
  systemd.user.tmpfiles.rules = [
    "d %h/.config/nvim 0755 - - -"
    "L+ %h/.config/nvim/init.lua - - - - ${nvimConfig}/init.lua"
    "L+ %h/.config/nvim/lua - - - - ${nvimConfig}/lua"
    "L+ %h/.config/nvim/doc - - - - ${nvimConfig}/doc"
    "C %h/.config/nvim/nvim-pack-lock.json - - - - ${./nvim-pack-lock.json}"

    "d %h/.local/share/nvim/site/pack/core 0755 - - -"
    "L+ %h/.local/share/nvim/site/pack/core/opt - - - - ${packOpt}"
  ];
}
