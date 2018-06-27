{ pkgs }:

let
    hothasktags = "${pkgs.haskellPackages.hothasktags}/bin/hothasktags";
    hasktags = "${pkgs.haskell.lib.justStaticExecutables pkgs.haskellPackages.hasktags}/bin/hasktags";
    fast-tags = "${pkgs.haskellPackages.fast-tags}/bin/fast-tags";
    hie = "${pkgs.hie82}/bin/hie";
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
          exec ${mytags} -c -x --ignore-close-implementation **/*.hs $fns
      else
          exec ${mytags} -c -x --ignore-close-implementation $fns
      fi
    '';
in
''
au BufWritePost *.hs            silent !${init-tags} %

let g:deoplete#sources.haskell = ['LanguageClient']
let g:LanguageClient_serverCommands = {
    \ 'haskell': ['${hie}', '-d', '--lsp'],
    \ }
" let g:stylish_haskell_command = ''${stylish-haskell}/bin/stylish-haskell'
let g:tagbar_type_haskell = {
    \ 'ctagsbin'  : '${hasktags}',
    \ 'ctagsargs' : '-x -c -o-',
    \ 'kinds'     : [
        \  'm:modules:0:1',
        \  'd:data: 0:1',
        \  'd_gadt: data gadt:0:1',
        \  't:type names:0:1',
        \  'nt:new types:0:1',
        \  'c:classes:0:1',
        \  'cons:constructors:1:1',
        \  'c_gadt:constructor gadt:1:1',
        \  'c_a:constructor accessors:1:1',
        \  'ft:function types:1:1',
        \  'fi:function implementations:0:1',
        \  'o:others:0:1'
    \ ],
    \ 'sro'        : '.',
    \ 'kind2scope' : {
        \ 'm' : 'module',
        \ 'c' : 'class',
        \ 'd' : 'data',
        \ 't' : 'type'
    \ },
    \ 'scope2kind' : {
        \ 'module' : 'm',
        \ 'class'  : 'c',
        \ 'data'   : 'd',
        \ 'type'   : 't'
    \ }
\ }

''
