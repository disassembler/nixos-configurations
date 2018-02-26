{ config, pkgs, lib, ... }:

with lib; {
  options.roles.work.enable = mkEnableOption "work role";
  options.roles.work.containers.enable = mkEnableOption "work containers";

  config = mkIf config.roles.work.enable {
    users.extraUsers.sam = {
      openssh.authorizedKeys.keys = config.attributes.private.sam_ssh_keys;
    };
    containers = mkIf config.roles.work.containers.enable {
      wyse = {
        privateNetwork = true;
        hostAddress = "10.39.0.3";
        localAddress = "10.39.0.4";
        enableTun = true;
        autoStart = true;
        config = { config, pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            openconnect
            tcpdump
            inetutils
            openssl
            tmux
            sudo
          ];
          systemd.services.openconnect = {
            description = "Wyse VPN";
            environment = { PATH = "/run/current-system/sw/bin"; PASSWORD = config.attributes.private.vpns.wyse.password; };
            path = [ pkgs.nettools ];
            serviceConfig = {
              Type = "simple";
              ExecStart = "${pkgs.bash}/bin/bash -c \"${pkgs.openconnect}/bin/openconnect -u ${config.attributes.private.vpns.wyse.user} ${config.attributes.private.vpns.wyse.host} <<< $PASSWORD\"";
              Restart = "always";
              RestartSec = 5;
            };
            wantedBy = [ "network.target" ];
            enable = true;
          };
          services.openssh.enable = true;
          users.extraUsers.sam = {
            isNormalUser = true;
            description = "Sam Leathers";
            uid = 1000;
            extraGroups = [ "wheel"];
            openssh.authorizedKeys.keys = config.attributes.private.sam_ssh_keys;
          };
        };
      };
      nginxdev = {
        privateNetwork = true;
        hostAddress = "10.39.0.5";
        localAddress = "10.39.0.6";
        autoStart = false;
        config = { config, pkgs, ... }:
        {
          networking.nameservers = [ "8.8.8.8" ];
          networking.firewall.enable = true;
          networking.firewall.allowedTCPPorts = [ 80 ];
          environment.systemPackages = with pkgs; [
            tmux
            sudo
            php
          ];
          services.nginx = {
            enable = true;
            httpConfig = ''
server {
      listen 80;
      listen [::]:80;
      server_name tt-rss.sarov.local;
      root /var/lib/tt-rss;
      access_log stdout;
      location / {
        index index.php;
      }
      location ~ .php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/phpfpm/tt-rss.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /var/lib/tt-rss/$fastcgi_script_name;
      }
}
              '';
          };
          services.postgresql.enable = true;
          services.postgresql.authentication = "local all all trust";
          services.tt-rss = {
            enable = true;
            selfUrlPath = "http://tt-rss.sarov.local";
            virtualHost = null;
          };
          services.openssh.enable = true;
          users.extraUsers.sam = {
            isNormalUser = true;
            description = "Sam Leathers";
            uid = 1000;
            extraGroups = [ "wheel"];
            openssh.authorizedKeys.keys = config.attributes.private.sam_ssh_keys;
          };
        };
      };
      ncc = {
        privateNetwork = true;
        hostAddress = "10.39.0.7";
        localAddress = "10.39.0.8";
        enableTun = true;
        autoStart = false;
        config = { config, pkgs, ... }:
        {
          networking.nat = {
            enable = true;
            internalInterfaces = ["eth0+"];
            externalInterface = "tun0";
          };
          environment.systemPackages = with pkgs; [
            tcpdump
            inetutils
            openssl
            tmux
            sudo
          ];
          services.openssh.enable = true;
          services.openvpn = {
            servers = {
              ncc = {
                autoStart = false;
                config = config.attributes.private.ncc-openvpn-config;
              };
            };
          };
          services.dnsmasq = {
            enable = true;
            extraConfig = ''
              server=/ncc.local/10.10.10.2
            '';
            servers = [
              "8.8.4.4"
              "8.8.8.8"
            ];
            resolveLocalQueries = true;
          };
          users.extraUsers.sam = {
            isNormalUser = true;
            description = "Sam Leathers";
            uid = 1000;
            extraGroups = [ "wheel"];
            openssh.authorizedKeys.keys = config.attributes.private.sam_ssh_keys;
          };
        };
      };
    };
  };
}
