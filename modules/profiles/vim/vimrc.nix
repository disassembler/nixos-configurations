{ stdenv, writeText, python, pkgs }:

let
    generic = builtins.readFile ./vimrc/general.vim;
    plug = import ./vimrc/pluginconfigurations.nix;
    haskell = pkgs.callPackage haskell/vimrc.nix {};
in

''
    ${generic}
    ${plug}
    ${haskell}
''
