{ config, pkgs, lib, ... }: 

with lib;

{
  config = {
    profiles.tmux.enable = true;
    time.timeZone = mkDefault "America/New_York";

    i18n = {
      consoleFont = "Lat2-Terminus16";
      consoleKeyMap = "us";
      defaultLocale = "en_US.UTF-8";
    };


    # You are not allowed to manage users manually
    users.mutableUsers = mkDefault true;

    # clean tmp on boot
    boot.cleanTmpDir = mkDefault true;

    # Recovery key, for times when you lock yourself out of system
    #users.extraUsers.root.openssh.authorizedKeys.keys = [ config.attributes.recoveryKey ];

    programs = {
      bash.enableCompletion = mkDefault true;
      ssh.forwardX11 = false;
      ssh.startAgent = true;
      #vim.defaultEditor = true;
    };

    # sane dnsmasq defaults
    services = {
      dnsmasq.extraConfig = ''
        strict-order # obey order of dns servers
      '';

      # sane journald defaults
      journald.extraConfig = ''
        SystemMaxUse=256M
      '';
      locate.enable = true;
      openssh.enable = true;
      openssh.permitRootLogin = "without-password";
    };

    boot.kernelModules = [ "tun" "fuse" ];
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.extraUsers.root.shell = mkOverride 50 "${pkgs.bashInteractive}/bin/bash";
    users.extraUsers.sam = {
      isNormalUser = true;
      description = "Sam Leathers";
      uid = 1000;
      extraGroups = [ "wheel" "docker" "disk" "video" "libvirtd" "adbusers" ];
      openssh.authorizedKeys.keys = config.attributes.private.sam_ssh_keys;
    };

    environment.systemPackages = with pkgs; [
      git
      screen
      nix-repl # repl for the nix language
      wget
      openssh
      openssl
      fasd
      bind
    ];
  };
}
