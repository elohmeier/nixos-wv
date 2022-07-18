{ config, lib, pkgs, ... }:

{
  services.mosquitto = {
    enable = true;

    listeners = [{
      port = 8883;

      # see https://tasmota.github.io/docs/MQTT/#mqtt-topic-definition
      users = {
        hass = {
          acl = [
            "readwrite cmnd/#"
            "readwrite stat/#"
            "readwrite tele/#"
            "readwrite homeassistant/#"
          ];
          passwordFile = "/var/lib/mosquitto/hass.passwd";
        };

        tasmota = {
          acl = [
            "readwrite cmnd/#"
            "readwrite stat/#"
            "readwrite tele/#"
            "readwrite homeassistant/#"
          ];
          passwordFile = "/var/lib/mosquitto/tasmota.passwd";
        };
      };

      settings = {
        certfile = "/var/lib/acme/def.lf42.de/fullchain.pem";
        keyfile = "/var/lib/acme/def.lf42.de/key.pem";

        # tasmota compatible, remember to configure keyType = "rsa2048" in security.acme
        tls_version = "tlsv1.2";
        ciphers = "ECDHE-RSA-AES128-GCM-SHA256";
      };
    }];
  };

  systemd.services.mosquitto.serviceConfig.SupplementaryGroups = "nginx"; # acme cert access

  networking.firewall.allowedTCPPorts = [ 8883 ];

  security.acme.certs."def.lf42.de".keyType = "rsa2048"; # https://tasmota.github.io/docs/TLS/#limitations
}
