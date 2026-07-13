{
  description = "evaniel's Neovim config, packaged as a NixOS module";

  outputs =
    { self, ... }:
    {
      nixosModules.default = import ./nvim.nix;
    };
}
