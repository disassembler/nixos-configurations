{ lib, config, pkgs, parameters}:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModprobeConfig = ''
    options resume=/dev/sda5
    options snd-hda-intel model=mbp5
    options hid_apple fnmode=2
  '';
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.enableUnstable = true;

  networking = {
    hostName = parameters.machine;
    hostId = parameters.hostId;
    nameservers = [ "127.0.0.1" ];
    networkmanager.enable = true;
    networkmanager.unmanaged = [ "interface-name:ve-*" ];
    extraHosts =
    ''
    '';
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "wlp3s0";
    };
    firewall = {
      enable = true;
      allowedUDPPorts = [ 53 4919 ];
      allowedTCPPorts = [ 4444 8081 3478 3000 8080 ];
    };
    bridges = {
      cbr0.interfaces = [ ];
    };
    interfaces = {
      cbr0 = {
        ipv4.addresses = [
          {
            address = "10.38.0.1";
            prefixLength = 24;
          }
        ];
      };
    };
  };

  security.pki.certificates = [ parameters.wedlake_ca_cert ];

  nix = {
    useSandbox = true;
    binaryCaches = [ "https://hydra.iohk.io" ];
    binaryCachePublicKeys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
    nixPath = [ "nixpkgs=/home/sam/nixpkgs/custom" "nixos-config=/etc/nixos/configuration.nix" ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = super: let self = super.pkgs; in {
      nixops = super.nixops.overrideDerivation (
        old: {
          patchPhase = ''
            substituteInPlace nix/eval-machine-info.nix \
                --replace 'system.nixosVersion' 'system.nixos.version'
          '';
        }
  );
    };
  };
  environment.systemPackages = with pkgs; [
    nixops
    dropbox
    gist
    dropbox-cli
    dmenu
    chromium
    gnupg
    gnupg1compat
    docker_compose
    niff
    androidsdk
    tmate
    htop
    i3-gaps
    xlockmore
    i3status
    feh
    imagemagick
    weechat
    rxvt_unicode-with-plugins
    xsel
    keepassx2
    tcpdump
    telnet
    xclip
    xpra
    p11_kit
    openconnect
    openconnect_gnutls
    gnutls
    nix-prefetch-git
    gitAndTools.gitflow
    tig
    python27Packages.gnutls
    unzip
    aws
    awscli
    aws_shell
    p7zip
    zip
    scrot
    remmina
    tdesktop
    keybase
    keybase-gui
    slack
    neomutt
    notmuch
    pythonPackages.goobook
    taskwarrior

  ];

  hardware = {
    pulseaudio = {
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
      #      configFile = pkgs.writeText "default.pa" ''
      #        load-module module-bluetooth-policy
      #        load-module module-bluetooth-discover
      #        load-module module-bluez5-device
      #        load-module module-bluez5-discover
      #'';
      
    };
    opengl.enable = true;
    opengl.extraPackages = [ pkgs.vaapiIntel ];
    facetimehd.enable = true;
    bluetooth = {
      enable = true;
      extraConfig = ''
        [general]
        Enable=Source,Sink,Media,Socket
      '';
    };
  };
  fonts.enableFontDir = true;
  fonts.enableCoreFonts = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fontconfig.dpi=150;
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
    offlineimap = {
      enable = true;
      path = [ pkgs.notmuch ];
    };
    printing = {
      enable = true;
      #drivers = [ pkgs.hplip ];
      browsing = true;
    };
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
    xserver = {
      xautolock = {
        enable = true;
        time = 5;
        locker = "${pkgs.xtrlock-pam}/bin/xtrlock-pam";
        nowlocker = "${pkgs.xtrlock-pam}/bin/xtrlock-pam";
        #killer = "${pkgs.systemd}/bin/systemctl suspend";
        #killtime = 30;
        extraOptions = [ "-detectsleep" ];
      };
      videoDrivers = [ "intel" ];
      libinput = {
        enable = true;
        disableWhileTyping = true;
      };
      autorun = true;
      enable = true;
      layout = "us";
      windowManager.i3 = {
        enable = true;
        extraSessionCommands = ''
          ${pkgs.xlibs.xset}/bin/xset r rate 200 60 # set keyboard repeat
          ${pkgs.feh} --bg-scale /home/sam/photos/20170503_183237.jpg
        '';
      };
      windowManager.i3.package = pkgs.i3-gaps;
      #windowManager.i3.configFile = import ../i3config.nix { inherit config; inherit pkgs; inherit parameters; };
      windowManager.default = "i3";
      displayManager.slim = {
        enable = true;
        defaultUser = "sam";
        theme = pkgs.fetchurl {
          url    = "https://github.com/nickjanus/nixos-slim-theme/archive/2.1.tar.gz";
          sha256 = "8b587bd6a3621b0f0bc2d653be4e2c1947ac2d64443935af32384bf1312841d7";
        };
      };
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
    kbfs = {
      enable = true;
      mountPoint = "/keybase";
    };
  };
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
    #extraOptions = "--iptables=false --ip-masq=false -b cbr0";
    #extraOptions = "--insecure-registry 10.80.0.49:5000";
  };
  virtualisation.libvirtd.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Custom dotfiles for sam user
  environment.etc."per-user/sam/gitconfig".text = import ../sam-dotfiles/git-config.nix;

  system.activationScripts.samdotfiles = {
    text = "ln -sfn /etc/per-user/sam/gitconfig /home/sam/.gitconfig";
    deps = [];
  };

}
