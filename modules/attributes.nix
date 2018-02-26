{ config, lib, pkgs, ... }:

with lib;
  
{
  options.attributes = {
    projectName = mkOption {
      description = "Name of the project";
      type = types.str;
      default = "sarov";
    };
    privateIPv4 = mkOption {
      description = "Private networking address.";
      default = "127.0.0.1";
      type = types.str;
    };
    private = mkOption {
      description = "Private attributes";
      default = {};
    };
    sshkeys = mkOption {
      description = "ssh keys";
      default = [];
      type = types.listOf types.str;
    };
  };
}
