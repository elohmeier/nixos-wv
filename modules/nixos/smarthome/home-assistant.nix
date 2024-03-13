{ config, lib, pkgs, ... }:

{
  services.home-assistant = {
    enable = true;

    extraComponents = [
      "fritzbox"
      "met"
      "mqtt"
      "radio_browser"
      "tado"
      "tasmota"
    ];

    config = {
      automation = "!include automations.yaml";
      scene = "!include scenes.yaml";

      config = { };
      device_automation = { };
      history = { };
      logbook = { };
      mobile_app = { };
      recorder.purge_keep_days = 14;
      ssdp = { };
      system_health = { };

      homeassistant = {
        auth_providers = [{ type = "homeassistant"; }];
        latitude = "53.633215";
        longitude = "10.0172642";
        name = "Home";
        time_zone = "Europe/Berlin";
        unit_system = "metric";
        country = "DE";
      };

      http = {
        server_host = [ "127.0.0.1" "::1" ];
        server_port = 8123;
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" "::1" ];
        ip_ban_enabled = true;
        login_attempts_threshold = 5;
      };
    };
  };

  systemd.services.home-assistant.preStart = ''
    touch /var/lib/hass/automations.yaml
    touch /var/lib/hass/scenes.yaml
  '';
}
