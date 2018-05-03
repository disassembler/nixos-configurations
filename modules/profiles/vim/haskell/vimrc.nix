{ pkgs }:

let
    hothasktags = "${pkgs.haskellPackages.hothasktags}/bin/hothasktags";
    hasktags = "${pkgs.haskellPackages.hasktags}/bin/hasktags -c";
    fast-tags = "${pkgs.haskellPackages.fast-tags}/bin/fast-tags";
    mytags = hasktags;
    stylish-haskell = pkgs.haskellPackages.stylish-haskell.overrideAttrs (oldAttrs: rec {
      doCheck = false;
    });
    init-tags = pkgs.writeScript "init-tags" ''
      #!${pkgs.zsh}/bin/zsh
      # fast-tags wrapper to generate tags automatically if there are none.

      setopt extended_glob
      
      fns=$@
      if [[ ! -r tags ]]; then
          echo Generating tags from scratch...
          exec ${mytags} **/*.hs $fns
      else
          exec ${mytags} $fns
      fi
    '';
in
''
au BufWritePost *.hs            silent !${init-tags} %
let g:stylish_haskell_command = '${stylish-haskell}/bin/stylish-haskell'
''
