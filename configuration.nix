# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, fetchgit, ... }:

let
  parameters = import ./parameters.nix;

  custom_modules = (import ./modules/modules-list.nix);

in {
  imports =
  [ # Include the results of the hardware scan.
    (./hardware-configurations + "/${parameters.machine}.nix")
    # Machine specific config
    (
    import (./machines + "/${parameters.machine}.nix") {
      inherit lib;
      inherit config;
      inherit pkgs;
      inherit parameters;
    }
    )
  ] ++ custom_modules;

  profiles.zsh.enable = true;
  attributes.private = parameters;
  #profiles.passopolis.enable = true;
  #profiles.etcd.enable = true;
  #users.extraUsers.sam = {
  #  isNormalUser = true;
  #  description = "Sam Leathers";
  #  uid = 1000;
  #  extraGroups = [ "wheel"];
  #  openssh.authorizedKeys.keys = parameters.sam_ssh_keys;
  #};

}
