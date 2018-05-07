{ config, pkgs, lib, ... }:
let
  customization = (import ./vim/customization.nix { pkgs = pkgs; });
  nvim = pkgs.neovim.override {
    vimAlias = true;
    configure = customization;
  };
  vim = pkgs.vim_configurable.customize { 
    name = "vim";
    vimrcConfig.vam = customization.vam;
    vimrcConfig.customRC = customization.customRC;
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
