{
  description = "nixos-wv";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;

  outputs = { self, nixpkgs }: {
    nixosConfigurations.hetznervm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./home-assistant.nix
        ({ config, lib, modulesPath, pkgs, ... }: {
          imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
          boot.loader.grub.device = "/dev/sda";
          boot.initrd.kernelModules = [ "nvme" ];
          fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
          system.stateVersion = "22.05";
          boot.cleanTmpDir = true;
          networking = {
            useNetworkd = true;
            useDHCP = false;
            hostName = "xahGh5gi";
            interfaces.ens3 = {
              useDHCP = true;
              ipv6 = {
                addresses = [{ address = "2a01:4f9:c011:6238::1"; prefixLength = 64; }];
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
          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC110wwsmO+Tp4Su9YOqq3mgUvYXrRfLEUncEFWQKXFNlGuEvs/IjKmMfX0wSH1Qw0GXSQP3OJ9cVyfsqpRurnz1WZTtmpjDy9Yx6cMer4E8SfdO7hea9Jub8jjGMfyVX3HK81dA1ffSY9KLsh+7GWuiLnZHYjHlbS3laH8Aeza3Ln66LUSEEOr0NYx4MZNl20iAaaUShUmJGIhf5/P5IGDLuIjbL/3ct0xrmJ1tBAGWtmE4Lopn5nkyZTh/2AW3T+liDo3jnXD018npd4XrT/+USOKRao2b343mcCrN1E4/vXsw7lUkwydQ4ZkdXY0pfFufdU6LHzODvbdeXlgjn2fxLS0vN+wOzmZMBhMQQVsra87hzilXArW4xq87HDAQScv+jH4gg+d8ijpyL5MeUf57yXgpu4eh7mD9d1nr5D+nEGzWPCakswvixM3sQFSuhH1T8uMgSUBQBWTkLnzAOO6aU5DZu2l24ftczRbPHPnNxUBYFNC5upwPvrnsU+YiCoI3M3D6yzGp+AVsvtqj877E0y+MmVvS22p9sYiTT6iV7fz86v7mphxPmVQs38LGLdImMAxFLVe9p1g6HpuOZXq+Lkeh7Bz4dWbAO3u1LzY9s+yMx8U240QMShA1qUIYwLpEeM8IBqeXnEaTp3+WhbEKj9XgaNhfYhipMY+/Tv2zQ== cardno:000611343949"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETizjNiMQOgdL2/Fv2NY4FDpP7wfmcP5faXK9ANHLM7 enno@nixos-mb4"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7OXq7COvJxoRQ2AQdo0HTJCITC6cPIZN/zs8XwCk4b enno@mb4"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6SC5B14IbROqLvuZWaHeBlI2syQUEl2oH43YjHLjXS4fAgfq7rowXk9kvZFm8So3vFRPX409IiMemzEo1s7r/5JqqOAjzc3iwXitVrL1uiFmry4P0j0by032N5P/q0CE9B2ARQXzafutaqwErqmtGm432Z5ifq3gFbUyax9AUqNuXRdHV3jM0mZrsvBHuE3da6jDg0pzQ3lbUojimt9yKE8Rue3Rhf94fqX7Fibc3TRCp+pBiPeJQUJoMmJ1DZbViUi7WrB7h1P0jSRVLVec9rG6PJbG3BWGjXro9MLN/9TpeymkBJYFlFlrhjedg1u/2NpeQmwd333/DcpIel8GrnUu+sPusCI1HHsmJQbxbzCWxDbQqIabQ5tq4TFaCX6ZWLlaIq7O3ofYv8YfUN5KdVU0Snwb/8o09FcLvu4FSW/L4WL3penaKqWfN03bQ6i1jsZ5KgYVdAgRK9ARx+Tg9DYSzua/rV2CzicAqScU32rKnORUAZS87rdxU6A0SFe7V5E4gmDxvAmCCtYCCYgwGsGHxmrgEGXkh8koBLVJA1MALq1bHieI2NSVC3LCVK5Ml6FXliPH9oeBMxZt8M4uo/1FDE1+6h5BAHF/6r89cUaxRm27AQaEHuS2Kpqc9KYphVW3W53d2GkaI6T/3yYJe2S6QAkVqjeHFUqUIfTq5+w== cardno:000611343941"
          ];
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
              addSSL = true;
              enableACME = true;
              locations."/".extraConfig = ''
                proxy_pass http://127.0.0.1:8123;
                proxy_set_header Host $host;
                proxy_redirect http:// https://;
                proxy_http_version 1.1;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection $connection_upgrade;
              '';
            };
          };

          security.acme = {
            defaults.email = "enno.richter+acme@fraam.de";
            acceptTerms = true;
          };
        })
      ];
    };
  };
}
