{ config, lib, pkgs, ... }:

{
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
          passwordFile = "/var/lib/mosquitto/tasmota.passwd";
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
            passwordFile = "/var/lib/mosquitto/hass.passwd";
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
