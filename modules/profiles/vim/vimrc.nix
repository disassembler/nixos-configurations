{ stdenv, writeText, python, pkgs }:

let
    generic = builtins.readFile ./vimrc/general.vim;
    plug = import ./vimrc/pluginconfigurations.nix;
    haskell = pkgs.callPackage haskell/vimrc.nix {};
    javascript = pkgs.callPackage javascript/vimrc.nix {};
in

''
 " wakatime
    let g:wakatime_Binary = "${pkgs.wakatime}/bin/wakatime"
    ${generic}
    ${plug}
    ${haskell}
    ${javascript}
''
