{ config, lib, pkgs, ... }:

{
  imports = [
    ./klipper.nix
    ./rpi3b.nix
  ];

  services.getty.autologinUser = "wilko";
  security.sudo.wheelNeedsPassword = false;
  nix.trustedUsers = [ "root" "@wheel" ];
  system.stateVersion = "22.05";
  networking.hostName = "rpi3-klipper";

  users.users = {
    mainUser = {
      name = "wilko";
      isNormalUser = true;
      home = "/home/wilko";
      createHome = true;
      useDefaultShell = true;
      uid = 1000;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = import ../ssh-keys.nix;
    };
    root.openssh.authorizedKeys.keys = import ../ssh-keys.nix;
  };
  users.mutableUsers = false;

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ];
  };

  programs.command-not-found.enable = false;

  time.timeZone = "Europe/Berlin";

  services.openssh = {
    enable = true;
    permitRootLogin = "prohibit-password";
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };

  systemd.coredump.extraConfig = "Storage=none";
  security.sudo.execWheelOnly = true;
}
