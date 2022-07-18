{ config, lib, pkgs, ... }:

{
  services.home-assistant = {
    enable = true;

    config = {
      automation = "!include automations.yaml";
      scene = "!include scenes.yaml";

      config = { };
      device_automation = { };
      fritzbox = { };
      history = { };
      logbook = { };
      met = { };
      mobile_app = { };
      mqtt.certificate = "/etc/ssl/certs/ca-certificates.crt";
      radio_browser = { };
      recorder.purge_keep_days = 14;
      ssdp = { };
      system_health = { };
      tasmota = { };

      homeassistant = {
        auth_providers = [{ type = "homeassistant"; }];
        latitude = "53.633215";
        longitude = "10.0172642";
        name = "Wilko";
        time_zone = "Europe/Berlin";
        unit_system = "metric";
      };

      http = {
        server_host = "127.0.0.1";
        server_port = 8123;
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" "::1" ];
      };
    };
  };

  systemd.services.home-assistant.preStart = ''
    touch /var/lib/hass/automations.yaml
    touch /var/lib/hass/scenes.yaml
  '';

}
