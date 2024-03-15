{ inputs, ... }:
{
  perSystem = { pkgs, system, ... }: {
    devShells.default =
      pkgs.mkShellNoCC {
        packages = [
          inputs.nixos-anywhere.packages.${system}.default
          pkgs.nixos-rebuild
        ];
      };

    packages = {
      inherit (pkgs) gotenberg tika-server-standard;
    };
  };
}
