{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.gotenberg;
in
{
  options.services.gotenberg = {
    enable = mkEnableOption "gotenberg";

    package = mkOption {
      type = types.package;
      default = pkgs.gotenberg;
      defaultText = literalExpression "pkgs.gotenberg";
      description = mdDoc "The Gotenberg package to use.";
    };

    port = mkOption {
      type = types.port;
      default = 3000;
      description = mdDoc "The port to listen on.";
    };
  };

  config = mkIf cfg.enable {

    systemd.services.gotenberg = {
      description = "Gotenberg";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/gotenberg --api-port ${toString cfg.port} --log-level info";

        # hardening
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
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [ "@system-service" ];
      } // lib.optionalAttrs (cfg.port < 1024) {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      };
    };
  };
}
