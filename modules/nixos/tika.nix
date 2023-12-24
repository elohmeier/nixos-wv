{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.tika;
in
{
  options.services.tika = {
    enable = mkEnableOption "tika";

    package = mkOption {
      type = types.package;
      default = pkgs.tika-server-standard;
      defaultText = literalExpression "pkgs.tika-server-standard";
      description = mdDoc "The Tika package to use.";
    };

    port = mkOption {
      type = types.port;
      default = 9998;
      description = mdDoc "The port to listen on.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.tika = {
      description = "Tika";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/tika-server-standard --port ${toString cfg.port}";

        CapabilityBoundingSet = "";
        DynamicUser = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" "~@privileged @setuid @keyring" ];
      } // lib.optionalAttrs (cfg.port < 1024) {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      };
    };
  };
}
