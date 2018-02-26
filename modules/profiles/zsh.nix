{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.profiles.zsh;
  zsh_config = import ./zsh/config.nix {
    inherit (pkgs) writeText zsh-prezto less;
  };
in {
  options.profiles.zsh = {
    enable = mkEnableOption "enable zsh profile";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      zsh
      zsh-prezto
      #(pkgs.lib.overrideDerivation pkgs.zsh-prezto (attrs: {
      #  rev = "237abad3280ba8418f9cded4bd8b57fef4c508da";
      #  name = "zsh-prezto-2017-03-28_rev237abad";
      #  src = pkgs.fetchgit {
      #    url = "https://github.com/disassembler/prezto";
      #    rev = "237abad3280ba8418f9cded4bd8b57fef4c508da";
      #    sha256 = "0xvfbjxhhldgyqjf7zpfgwfcfa6w7z8d9ar1hv2hwfsir0ggqhw4";
      #    fetchSubmodules = true;
      #  };
      #}))
    ];
    environment.etc = zsh_config.environment_etc;
    programs = {
      zsh = {
        enable = true;
        syntaxHighlighting = {
          enable = true;
          highlighters = [ "main" "pattern" ];
          patterns = {
            "rm -rf *" = "fg=white,bold,bg=red";
          };
        };

      };
    };
    users.defaultUserShell = pkgs.zsh;
  };
}
