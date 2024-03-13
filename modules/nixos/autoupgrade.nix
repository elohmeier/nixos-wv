{ config, lib, pkgs, ... }:

{
  # set this elsewhere
  # system.autoUpgrade.flake = "github:elohmeier/nixos-wv#XXX";

  system.autoUpgrade = {
    enable = true;
    operation = "boot";

    allowReboot = true;
    rebootWindow = { lower = "03:00"; upper = "05:00"; };
    flags = [ "-L" ]; # print build logs
  };
}
