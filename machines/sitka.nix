{ lib, config, pkgs, parameters }:

{
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.zfs.enableUnstable = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking = {
    hostName = parameters.machine;
    hostId = parameters.hostId;
    nameservers = [ "10.39.0.3" ];
    networkmanager.enable = true;
    networkmanager.unmanaged = [ "interface-name:ve*" "interface-name:cbr0" "interface-name:tun*" "interface-name:br*" ];
    networkmanager.useDnsmasq = false;
    extraHosts =
    ''
      10.39.0.4 wyse.${parameters.machine}.local
      10.39.0.3 ${parameters.machine}
    '';
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "wlp3s0";
      forwardPorts = [
        #{ sourcePort = 25; destination = "127.0.0.1:1025"; proto = "tcp"; }
        #{ sourcePort = 1194; destination = "10.40.33.20:1194"; proto = "udp"; }
      ];
    };
    firewall = {
      enable = true;
      allowedUDPPorts = [ 53 4919 ];
      allowedTCPPorts = [ 4444 8081 3478 3000 8080 25 8025 1025 ];
    };
    bridges = {
      cbr0.interfaces = [ ];
    };
    interfaces = {
      cbr0 = {
        ipAddress = "10.38.0.1";
        prefixLength = 24;
      };
    };
  };

  security.pki.certificates = [ parameters.wedlake_ca_cert ];

  # Set your time zone.
  time.timeZone = "America/New_York";

  nix = {
    useSandbox = true;
    package = pkgs.nixUnstable;
    nixPath = [
      #"nixpkgs=/home/sam/nixpkgs/nixpkgs-atrust"
      "nixpkgs=https://nixos.org/channels/nixos-17.09/nixexprs.tar.xz"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
  };
  nixpkgs.config = {
    allowUnfree = true;
    #chromium = {
    #  jre = false;
    #  enableGoogleTalkPlugin = true;
    #  enablePepperPDF = true;
    #};
    #packageOverrides = pkgs: rec {
    #  weechat = pkgs.weechat.override {
    #    extraBuildInputs = [ pkgs.pythonPackages.potr ];
    #  };
    #};
    #packageOverrides = super: let self = super.pkgs; in {
    #  sway = super.sway.overrideDerivation (old: {
    #    name = "sway-0.15-rc1";
    #    src = pkgs.fetchFromGitHub {
    #      owner = "Sircmpwn";
    #      repo = "sway";
    #      rev = "0.15-rc1";
    #      sha256 = "10pkbl7fjgynfs2z15gf53x1v0kxhky7f1z92z2mbp50w288d69j";
    #    };
    #  });
    #  wlc = super.wlc.overrideDerivation (old: {
    #    name = "wlc-0.0.10";
    #    src = pkgs.fetchFromGitHub {
    #      owner = "Cloudef";
    #      repo = "wlc";
    #      rev = "v0.0.10";
    #      fetchSubmodules = true;
    #      sha256 = "09kvwhrpgkxlagn9lgqxc80jbg56djn29a6z0n6h0dsm90ysyb2k";
    #    };
    #  });
    #};
  };
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
    pandoc
    #(pkgs.wine.override { wineBuild = "wineWow"; })
    keybase-gui
    docker_compose
    firefox
    niff
    nixops
    androidsdk
    weechat
    sway
    xwayland
    gist
    dropbox
    dropbox-cli
    nextcloud
    tmate
    google-drive-ocamlfuse
    ack
    cmus
    gnupg
    gnupg1compat
    htop
    i3-gaps
    i3status
    imagemagick
    owncloudclient
    tcpdump
    opensc
    pcsctools
    p11_kit
    openconnect
    openconnect_gnutls
    gnutls
    python27Packages.gnutls
    nix-prefetch-git
    gitAndTools.gitflow
    git
    tig
    unzip
    aws
    awscli
    binutils
    elfutils
    mplayer
    patchelf
    aws_shell
    telnet
  ];

  hardware = {
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };
    #opengl.enable = true;
    #opengl.extraPackages = [ pkgs.vaapiIntel ];
  };

  fonts.enableFontDir = true;
  fonts.enableCoreFonts = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fontconfig.dpi=90;
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
  programs.adb.enable = true;

  powerManagement.enable = true;

  services = {
    openssh.enable = true;
    mailhog.enable = true;
    #grafana = {
    #  enable = true;
    #  addr = "0.0.0.0";
    #};
    mongodb.enable = true;
    udev.extraRules = ''
      # Allow user access to some USB devices.
      SUBSYSTEM=="usb", ATTR{idVendor}=="04e6", ATTR{idProduct}=="e001", TAG+="uaccess", RUN{builtin}+="uaccess"
    '';
    compton = {
      enable = true;
      shadowExclude = [''"_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"''];
      extraOptions = ''
      opacity-rule = [
      "95:class_g = 'URxvt' && !_NET_WM_STATE@:32a",
      "0:_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
      ];
      '';
    };
    geoclue2.enable = pkgs.lib.mkForce false;
    telepathy.enable = pkgs.lib.mkForce false;
    keybase.enable = true;
    kbfs.enable = true;
    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
      browsing = true;
    };
    xserver = {
      xautolock = {
        enable = true;
        time = 5;
        #locker = "${pkgs.xtrlock-pam}/bin/xtrlock-pam";
        #nowlocker = "${pkgs.xtrlock-pam}/bin/xtrlock-pam";
        #killer = "${pkgs.systemd}/bin/systemctl suspend";
        #killtime = 30;
        #extraOptions = [ "-detectsleep" ];
      };
      libinput.enable = false;
      videoDrivers = [ "intel" ];
      multitouch.enable = true;
      autorun = true;
      enable = true;
      layout = "us";
      windowManager.i3 = {
        enable = true;
        #extraSessionCommands = ''
        #  ${pkgs.feh} --bg-scale /home/sam/photos/20170503_183237.jpg
        #'';
      };
      windowManager.i3.package = pkgs.i3-gaps;
      displayManager.sessionCommands = ''
        # Set GTK_PATH so that GTK+ can find the Xfce theme engine.
        export GTK_PATH=${pkgs.xfce.gtk_xfce_engine}/lib/gtk-2.0

        # Set GTK_DATA_PREFIX so that GTK+ can find the Xfce themes.
        export GTK_DATA_PREFIX=${config.system.path}

        # Set GIO_EXTRA_MODULES so that gvfs works.
        export GIO_EXTRA_MODULES=${pkgs.xfce.gvfs}/lib/gio/modules
      '';
      displayManager.lightdm = {
        enable = true;
        background = "/etc/lightdm/background.jpg";
      };
      #displayManager.lightdm.autoLogin = {
      #  enable = true;
      #  user = "sam";
      #};
      windowManager.default = "i3";
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
        address=/remote.atrust.com/204.115.117.34
        address=/remote2.atrust.com/204.115.117.33
        address=/auth1.atrust.com/54.219.142.186
        address=/auth2.atrust.com/204.115.117.12
        address=/samdev.infra.atrust.com/104.131.144.226
        cname=stage.salestreamsoft.com,a9e970a14d74511e7afcc0aff53ff0df-1411737340.us-west-2.elb.amazonaws.com
        server=/atrust.com/192.168.2.10
        server=/infra.salestream.lan/10.80.0.49
        server=/infra.atrust.com/8.8.8.8
        server=/ncc.local/10.10.10.2
        server=/wedlake.lan/10.40.33.20
      '';
      servers = [
        "8.8.4.4"
        "8.8.8.8"
      ];
      resolveLocalQueries = false;
    };
    redis.enable = true;

    openvpn = {
      servers = {
        prophet = {
          autoStart = false;
          config = parameters.prophet-openvpn-config;
        };
        buddygarden = {
          autoStart = false;
          config = parameters.buddygarden-openvpn-config;
        };
      };
    };
    pcscd.enable = true;
    zfs = {
      autoScrub.enable = true;
      autoSnapshot = {
        enable = true;
        monthly = 1;
        frequent = 2;
      };
    };
  };

  system.stateVersion = "17.09"; # Did you read the comment?

}
