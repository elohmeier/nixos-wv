{
  description = "nixos-wv";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      hetznervm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hetznervm ];
      };
    };
  };
}
