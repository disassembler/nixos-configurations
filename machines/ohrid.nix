{ lib, config, pkgs, parameters}:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.enableUnstable = true;

  networking = {
    hostName = parameters.machine;
    hostId = "8c7233f4";
    nameservers = [ "127.0.0.1" ];
    networkmanager.enable = true;
    networkmanager.unmanaged = [ "interface-name:ve-*" ];
    extraHosts =
    ''
    '';
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "wlp2s0";
    };
    firewall = {
      enable = true;
      allowedUDPPorts = [ 53 ];
    };
  };

  security.pki.certificates = [ parameters.wedlake_ca_cert ];

  nixpkgs.config = {
    allowUnfree = true;
    chromium = {
      jre = false;
      enableGoogleTalkPlugin = true;
      enablePepperPDF = true;
    };
  };
  environment.systemPackages = with pkgs; [
    dropbox
    dropbox-cli
    dmenu
    chromium
    gnupg
    gnupg1compat
    htop
    i3
    xlockmore
    i3status
    feh
    imagemagick
    weechat
    rxvt_unicode-with-plugins
    xsel
    keepassx2
    tcpdump
    xclip
    xpra
    p11_kit
    openconnect
    openconnect_gnutls
    gnutls
    python27Packages.gnutls
    unzip
    p7zip
    zip
    scrot
    remmina
    tdesktop
    keybase
    keybase-gui
    slack
  ];

  hardware = {
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };
    opengl.extraPackages = [ pkgs.vaapiIntel ];
  };
  fonts.enableFontDir = true;
  fonts.enableCoreFonts = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    corefonts
    fira # monospaced
    powerline-fonts
    inconsolata
    liberation_ttf
    dejavu_fonts
    bakoma_ttf
    gentium
    ubuntu_font_family
    terminus_font
    unifont # some international languages
  ];

  services = {
    xserver = {
      videoDrivers = [ "intel" ];
      multitouch.enable = true;
      autorun = true;
      enable = true;
      layout = "us";
      windowManager.i3.enable = true;
      windowManager.spectrwm.enable = true;
      windowManager.i3.configFile = import ../i3config.nix { inherit config; inherit pkgs; inherit parameters; };
      windowManager.default = "i3";
      displayManager.slim = {
        enable = true;
        defaultUser = "sam";
        theme = pkgs.fetchurl {
          url    = "https://github.com/nickjanus/nixos-slim-theme/archive/2.1.tar.gz";
          sha256 = "8b587bd6a3621b0f0bc2d653be4e2c1947ac2d64443935af32384bf1312841d7";
        };
      };
      synaptics.additionalOptions = ''
        Option "VertScrollDelta" "-100"
        Option "HorizScrollDelta" "-100"
      '';
      synaptics.enable = true;
      synaptics.tapButtons = true;
      synaptics.fingersMap = [ 0 0 0 ];
      synaptics.buttonsMap = [ 1 3 2 ];
      synaptics.twoFingerScroll = true;
    };
    dnsmasq = {
      enable = true;
      extraConfig = ''
        address=/crate.wedlake.lan/2601:98a:4101:bff0:d63d:7eff:fe4d:c47f
        server=/wedlake.lan/2601:98a:4101:bff0:d63d:7eff:fe4d:c47f
      '';
      servers = [
        "8.8.4.4"
        "8.8.8.8"
      ];
      resolveLocalQueries = false;
    };

    openvpn = {
      servers = {
        prophet = {
          autoStart = false;
          config = parameters.prophet-openvpn-config;
        };
      };
    };
    keybase.enable = true;
    kbfs.enable = true;
  };
  virtualisation.docker.enable = true;
  #virtualisation.docker.enableOnBoot = true;
  virtualisation.docker.storageDriver = "zfs";
  security.sudo.wheelNeedsPassword = false;

  # Custom dotfiles for sam user
  environment.etc."per-user/sam/gitconfig".text = import ../sam-dotfiles/git-config.nix;

  system.activationScripts.samdotfiles = {
    text = "ln -sfn /etc/per-user/sam/gitconfig /home/sam/.gitconfig";
    deps = [];
  };

}
