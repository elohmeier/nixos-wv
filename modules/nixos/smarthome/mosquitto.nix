{ config, lib, pkgs, ... }:

{
  sops.secrets."hass.passwd".restartUnits = [ "mosquitto.service" ];
  sops.secrets."tasmota.passwd".restartUnits = [ "mosquitto.service" ];

  services.mosquitto = {
    enable = true;

    listeners = [{
      port = 8883;

      # see https://tasmota.github.io/docs/MQTT/#mqtt-topic-definition
      users = {
        tasmota = {
          acl = [
            "readwrite cmnd/#"
            "readwrite stat/#"
            "readwrite tele/#"
            "readwrite tasmota/#"
          ];
          passwordFile = config.sops.secrets."tasmota.passwd".path;
        };
      };

      settings = {
        certfile = "/var/lib/acme/def.lf42.de/fullchain.pem";
        keyfile = "/var/lib/acme/def.lf42.de/key.pem";
      };
    }
      {
        port = 1883;
        address = "127.0.0.1";

        # see https://tasmota.github.io/docs/MQTT/#mqtt-topic-definition
        users = {
          hass = {
            acl = [
              "readwrite cmnd/#"
              "readwrite stat/#"
              "readwrite tele/#"
              "readwrite tasmota/#"
            ];
            passwordFile = config.sops.secrets."hass.passwd".path;
          };
        };
      }];
  };

  systemd.services.mosquitto.serviceConfig.SupplementaryGroups = "nginx"; # acme cert access

  networking.firewall.allowedTCPPorts = [ 8883 ];

  security.acme.certs."def.lf42.de" = {
    keyType = "rsa2048"; # https://tasmota.github.io/docs/TLS/#limitations
    postRun = "systemctl restart mosquitto.service";
  };
}
