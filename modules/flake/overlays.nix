{ self, inputs, ... }:
{
  flake.overlays.default = self: super: {
    gotenberg = self.callPackage ../../packages/gotenberg { };
    tika-server-standard = self.callPackage ../../packages/tika-server-standard { };
  };

  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      # Apply default overlay to provide packages for NixOS tests &
      # configurations.
      overlays = [
        self.overlays.default
      ];
    };
  };
}
