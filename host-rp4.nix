{ config, pkgs, ... }:

{
  imports = [
    ./hardware/rp4.nix
    ./modules/common.nix
    ./modules/consul/client.nix
    ./modules/remote-builder
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

  services.consul.catalog = [
    {
      name = "kodi";
      port = 8080;
      tags = (import modules/lib/traefik.nix).tagsForHost "tv";
    }
  ];
}
