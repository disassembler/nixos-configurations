{ pkgs }:

let
  # this is the vimrc.nix from above
  vimrc   = pkgs.callPackage ./vimrc.nix {};

  # and the plugins.nix from above
  plugins = pkgs.callPackage ./plugins.nix {};
in
{
  customRC = vimrc;
  vam = {
    knownPlugins = pkgs.vimPlugins // plugins;
    pluginDictionaries = [
      {
        names = [
          "vim-airline-themes"
          "ctrlp"
          "fugitive"
          "surround"
          "vim-markdown"
          "ale"
          "gitgutter"
          "vim-nix"
          "deoplete_nvim"
          "deoplete-go"
          "deoplete-rust"
          "repeat"
          "nerdtree"
          "UltiSnips"
          "vim-colorschemes"
          "vim-colors_atelier-schemes"
          "vim-lastplace"
          "vim-go"
          "yankring"
          "splice_vim"
          "vim_jsx"
          "vim_javascript"
          "vim_ps1"
          "haskell_vim"
          "vim-docbk"
          "vim-hoogle"
          "vim-docbk-snippets"
          "markdown_wiki"
          #"vim_stylish_haskell"
          "haskell_vim"
          "tagbar"
          "LanguageClient-neovim"
          "wakatime"
        ];
      }
    ];
  };
}
