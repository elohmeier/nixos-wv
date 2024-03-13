{ config, lib, modulesPath, pkgs, ... }:
{
  imports = [
    ./home-assistant.nix
    ./mosquitto.nix
  ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    upstreams.hass.servers."127.0.0.1:8123" = { };

    virtualHosts."def.lf42.de" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://hass";
        proxyWebsockets = true;
      };
    };
  };
}
