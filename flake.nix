{
  description = "nixos-wv";

  inputs = {
    nixinate.inputs.nixpkgs.follows = "nixpkgs";
    nixinate.url = "github:elohmeier/nixinate";
    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;
  };

  outputs = { self, nixinate, nixpkgs }: {
    apps = nixinate.nixinate.aarch64-darwin self;

    nixosConfigurations = {
      hetznervm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hetznervm
          { _module.args.nixinate = { host = "def.lf42.de"; sshUser = "root"; buildOn = "remote"; }; }
        ];
      };

      rpi3-klipper = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [ ./rpi3-klipper ];
      };
    };
  };
}
