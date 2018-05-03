{ config, pkgs, lib, ... }:
let
  nvim = pkgs.neovim.override {
    vimAlias = true;
    configure = (import ./vim/customization.nix { pkgs = pkgs; });
  };
in with lib; {
  config = {
    environment.systemPackages = [ 
      nvim
      pkgs.ctags
      #pkgs.python
      #pkgs.python35Packages.neovim
    ];
  };
  
}
