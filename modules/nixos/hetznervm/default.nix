{ config, lib, modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./home-assistant.nix
    ./mosquitto.nix
  ];
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
  system.stateVersion = "22.05";
  boot.cleanTmpDir = true;
  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "smarthomenix";
    interfaces.ens3 = {
      useDHCP = true;
      ipv6 = {
        addresses = [{ address = "2a01:4f8:c012:80b2::1"; prefixLength = 64; }];
      };
    };
    # reduce noise coming from www if
    firewall.logRefusedConnections = false;
    firewall.allowedTCPPorts = [ 80 443 ];
  };
  # prevents creation of the following route (`ip -6 route`):
  # default dev lo proto static metric 1024 pref medium
  systemd.network.networks."40-ens3".routes = [
    { routeConfig = { Gateway = "fe80::1"; }; }
  ];
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };
  users.users.root.openssh.authorizedKeys.keys = import ../ssh-keys.nix;
  services.fail2ban.enable = true;
  environment.systemPackages = with pkgs; [ gitMinimal btop ];
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."def.lf42.de" = {
      forceSSL = true;
      enableACME = true;
      locations."/".extraConfig = ''
        proxy_http_version 1.1;
        proxy_pass http://127.0.0.1:8123;
        proxy_redirect http:// https://;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };

  security.acme = {
    defaults.email = "wilko.volckens@web.de";
    acceptTerms = true;
  };
}
