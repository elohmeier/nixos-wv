{ self, inputs, lib, withSystem, ... }:
let
  nixosSystemFor = system: modules:
    let
      pkgs = withSystem system ({ pkgs, ... }: pkgs);
    in
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit lib; };
      modules = [
        {
          _module.args = {
            pkgs = lib.mkForce pkgs;
          };
        }
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        inputs.srvos.modules.nixos.mixins-nginx
        inputs.srvos.modules.nixos.server
        self.nixosModules.default
      ] ++ modules;
    };

in
{
  flake.nixosModules = rec {
    default = ({ config, pkgs, ... }: {
      imports = [
        gotenberg
        tailscale
        tika
      ];

      # mitigate https://github.com/NixOS/nix/issues/8502
      services.logrotate.checkConfig = false;

      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      security.acme = {
        acceptTerms = true;
        defaults.email = "wilko.volckens@web.de";
      };

      services.fail2ban.enable = true;

      users.users.root.shell = pkgs.fish;
      users.users.root.openssh.authorizedKeys.keys = [
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDrRFPTI7Dspol0HbM96RyGpUfvkC13IkCb4f6BFeZifRV5TOdocZQXKazCN8yBSeXPxIP5GVKv0vNglL1QMcP4=" # tp3
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLAUxgxfb28NybtTCWjRUKuDvbNai4fZzeIIG4/YTAWIO6VTklmD6HiEVrG4ASRfaPv0Py48POGliXF+7gDU0j0= enno@secretive.mb4.local"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETizjNiMQOgdL2/Fv2NY4FDpP7wfmcP5faXK9ANHLM7 enno@nixos-mb4"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETrOUFWleH/RZeJItrzg/shmEbMYW3lo4jF5QsQ7dZJ eddsa-key-RavenUSSD"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7OXq7COvJxoRQ2AQdo0HTJCITC6cPIZN/zs8XwCk4b enno@mb4"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC110wwsmO+Tp4Su9YOqq3mgUvYXrRfLEUncEFWQKXFNlGuEvs/IjKmMfX0wSH1Qw0GXSQP3OJ9cVyfsqpRurnz1WZTtmpjDy9Yx6cMer4E8SfdO7hea9Jub8jjGMfyVX3HK81dA1ffSY9KLsh+7GWuiLnZHYjHlbS3laH8Aeza3Ln66LUSEEOr0NYx4MZNl20iAaaUShUmJGIhf5/P5IGDLuIjbL/3ct0xrmJ1tBAGWtmE4Lopn5nkyZTh/2AW3T+liDo3jnXD018npd4XrT/+USOKRao2b343mcCrN1E4/vXsw7lUkwydQ4ZkdXY0pfFufdU6LHzODvbdeXlgjn2fxLS0vN+wOzmZMBhMQQVsra87hzilXArW4xq87HDAQScv+jH4gg+d8ijpyL5MeUf57yXgpu4eh7mD9d1nr5D+nEGzWPCakswvixM3sQFSuhH1T8uMgSUBQBWTkLnzAOO6aU5DZu2l24ftczRbPHPnNxUBYFNC5upwPvrnsU+YiCoI3M3D6yzGp+AVsvtqj877E0y+MmVvS22p9sYiTT6iV7fz86v7mphxPmVQs38LGLdImMAxFLVe9p1g6HpuOZXq+Lkeh7Bz4dWbAO3u1LzY9s+yMx8U240QMShA1qUIYwLpEeM8IBqeXnEaTp3+WhbEKj9XgaNhfYhipMY+/Tv2zQ== cardno:000611343949"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6SC5B14IbROqLvuZWaHeBlI2syQUEl2oH43YjHLjXS4fAgfq7rowXk9kvZFm8So3vFRPX409IiMemzEo1s7r/5JqqOAjzc3iwXitVrL1uiFmry4P0j0by032N5P/q0CE9B2ARQXzafutaqwErqmtGm432Z5ifq3gFbUyax9AUqNuXRdHV3jM0mZrsvBHuE3da6jDg0pzQ3lbUojimt9yKE8Rue3Rhf94fqX7Fibc3TRCp+pBiPeJQUJoMmJ1DZbViUi7WrB7h1P0jSRVLVec9rG6PJbG3BWGjXro9MLN/9TpeymkBJYFlFlrhjedg1u/2NpeQmwd333/DcpIel8GrnUu+sPusCI1HHsmJQbxbzCWxDbQqIabQ5tq4TFaCX6ZWLlaIq7O3ofYv8YfUN5KdVU0Snwb/8o09FcLvu4FSW/L4WL3penaKqWfN03bQ6i1jsZ5KgYVdAgRK9ARx+Tg9DYSzua/rV2CzicAqScU32rKnORUAZS87rdxU6A0SFe7V5E4gmDxvAmCCtYCCYgwGsGHxmrgEGXkh8koBLVJA1MALq1bHieI2NSVC3LCVK5Ml6FXliPH9oeBMxZt8M4uo/1FDE1+6h5BAHF/6r89cUaxRm27AQaEHuS2Kpqc9KYphVW3W53d2GkaI6T/3yYJe2S6QAkVqjeHFUqUIfTq5+w== cardno:000611343941"
      ];

      programs.fish = {
        enable = true;
        useBabelfish = true;
        interactiveShellInit = ''
          set -U fish_greeting
        '';
      };

      environment.systemPackages = with pkgs; [ btop ncdu ];
    });

    borgbackup = ./borgbackup.nix;
    gotenberg = ./gotenberg.nix;
    tailscale = ./tailscale.nix;
    tika = ./tika.nix;
  };

  flake.nixosConfigurations = {
    srv1 = nixosSystemFor "aarch64-linux" [
      (import ./disko/btrfs.nix { inherit lib; })
      inputs.srvos.modules.nixos.hardware-hetzner-cloud-arm
      ./paperless.nix
      { system.stateVersion = "23.11"; }
    ];

    smarthome = nixosSystemFor "x86_64-linux" [
      inputs.srvos.modules.nixos.hardware-hetzner-cloud
      ./smarthome
      ./autoupgrade.nix
      {
        system.stateVersion = "22.05";
        system.autoUpgrade.flake = "github:elohmeier/nixos-wv#smarthome";
      }
    ];

    rpi3-klipper = nixosSystemFor "aarch64-linux" [
      ./rpi3-klipper
    ];
  };
}
