{ config, pkgs, ... }:

{
  imports = [
    ./hardware/rp4.nix
    ./modules/common.nix
  ];

  sound.enable = true;

  # KODI
  services.xserver.enable = true;
  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "kodi";

  users.extraUsers.kodi.isNormalUser = true;

  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 8080 ];
  };
}
