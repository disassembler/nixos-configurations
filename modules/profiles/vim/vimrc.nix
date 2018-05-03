{ stdenv, writeText, python, pkgs }:

let
    generic = builtins.readFile ./vimrc/general.vim;
    #plug = import ./vimrc/pluginconfigurations.nix;
    haskell = pkgs.callPackage haskell/vimrc.nix {};
in

''
    ${generic}
    ${haskell}

let g:ycm_server_keep_logfiles = 1
let g:ycm_server_log_level = 'debug'
''
