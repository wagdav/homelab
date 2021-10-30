{ config, pkgs, ... }:

{
  imports = [ ./consul-catalog.nix ];

  sound.enable = true;

  services.xserver.enable = true;
  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.desktopManager.kodi.package = pkgs.kodi.withPackages (p: with p; [ kodi-platform youtube ]);
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "kodi";

  users.users.kodi = {
    isNormalUser = true;
    extraGroups = [ "video" ];
  };

  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 8080 ];
  };

  services.consul.catalog = [
    {
      name = "kodi";
      port = 8080;
      tags = (import lib/traefik.nix).tagsForHost "tv";
    }
  ];

  nixpkgs.overlays = [
    (self: super: {
      kodi = super.kodi.override {
        sambaSupport = false;
        rtmpSupport = false;
        joystickSupport = false;
      };
    })
  ];
}
