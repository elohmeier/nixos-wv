{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.tailscale;
  allLinks = cfg.httpServices ++ cfg.links;
in
{
  options.ptsd.tailscale = {
    enable = mkEnableOption "tailscale";
    ip = mkOption {
      type = types.str;
    };
    fqdn = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {

    services.tailscale = {
      enable = true;
      permitCertUid = "tailscale-cert";
    };

    services.fail2ban.ignoreIP = [ "100.64.0.0/10" ];

    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
    };

    users.groups.tailscale-cert = { };
    users.users.tailscale-cert = {
      group = "tailscale-cert";
      isSystemUser = true;
    };

    systemd.services.tailscale-cert = {
      description = "fetch tailscale host TLS certificate";
      after = [ "network-online.target" "tailscale.service" ];
      wants = [ "network-online.target" "tailscale.service" ];
      serviceConfig = {
        ExecStart = ''${config.services.tailscale.package}/bin/tailscale cert "${cfg.fqdn}"'';
        ExecStartPost = "+" + (pkgs.writeShellScript "tailscale-cert-post" ''
          cat "${cfg.fqdn}.crt" "${cfg.fqdn}.key" > "${cfg.fqdn}.pem"
          chown tailscale-cert:tailscale-cert "${cfg.fqdn}.pem"
          chmod 640 "${cfg.fqdn}.key"
          chmod 640 "${cfg.fqdn}.pem"
          systemctl --no-block try-reload-or-restart nginx.service
        '');
        StateDirectory = "tailscale-cert";
        WorkingDirectory = "/var/lib/tailscale-cert";
        User = "tailscale-cert";
        Group = "tailscale-cert";
      };
      startAt = "daily";
    };

    systemd.services.nginx = {
      requires = [ "tailscale-cert.service" ];
      after = [ "tailscale-cert.service" ];
      serviceConfig.SupplementaryGroups = "tailscale-cert";
    };

    services.nginx.virtualHosts = {
      "${cfg.fqdn}" = {
        listenAddresses = [ cfg.ip ];
        forceSSL = true;
        sslCertificate = "/var/lib/tailscale-cert/${cfg.fqdn}.crt";
        sslCertificateKey = "/var/lib/tailscale-cert/${cfg.fqdn}.key";
      };
    };
  };
}
