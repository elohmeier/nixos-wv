{
  inputs = {
    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko";
    };
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      url = "github:hercules-ci/flake-parts";
    };
    nixos-anywhere = {
      inputs = {
        disko.follows = "disko";
        flake-parts.follows = "flake-parts";
        nixos-stable.follows = "nixpkgs";
      };
      url = "github:nix-community/nixos-anywhere";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvos = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/srvos";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      imports = [ ./modules inputs.treefmt-nix.flakeModule ];
    };
}
