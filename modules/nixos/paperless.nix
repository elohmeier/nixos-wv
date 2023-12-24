{ config, lib, pkgs, ... }:

{
  services.nginx = {
    upstreams.paperless.servers."127.0.0.1:${toString config.services.paperless.port}" = { };

    virtualHosts = {
      "${config.ptsd.tailscale.fqdn}" = {
        locations."/" = {
          proxyPass = "http://paperless";
          proxyWebsockets = true;
        };
      };
    };
  };

  ptsd.tailscale = {
    enable = true;
    ip = "100.103.195.31";
    fqdn = "srv1.tail71491.ts.net";
  };

  services.gotenberg.enable = true;
  services.tika.enable = true;

  sops.secrets.paperless-password = {
    restartUnits = [
      "paperless-scheduler.service"
      "paperless-copy-password.service"
    ];
  };

  services.paperless = {
    enable = true;
    passwordFile = config.sops.secrets.paperless-password.path;
    extraConfig = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = builtins.toJSON {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
      PAPERLESS_FILENAME_FORMAT = "{document_type}/{created_year}-{created_month}/{created_year}-{created_month}-{created_day} {correspondent} {title}";

      PAPERLESS_TIKA_ENABLED = "1";
      PAPERLESS_TIKA_ENDPOINT = "http://localhost:${toString config.services.tika.port}";
      PAPERLESS_TIKA_GOTENBERG_URL = "http://localhost:${toString config.services.gotenberg.port}";
    };
    consumptionDirIsPublic = true;
  };

  sops.defaultSopsFile = ../../secrets/srv1.yaml;

  # services.borgbackup.jobs.hetzner = {
  #   repo = "ssh://u380848-sub2@u380848.your-storagebox.de:23/./borg";
  #   paths = [
  #     "/var/lib/paperless"
  #   ];
  #   exclude = [
  #     "/var/lib/paperless/log/"
  #   ];
  # };
}
