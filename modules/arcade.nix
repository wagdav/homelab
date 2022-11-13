{ config, pkgs, lib, ... }:

{
  imports = [ ./consul-catalog.nix ];

  sound.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "zsnes";
  services.xserver.displayManager.defaultSession = "zsnes";
  services.xserver.displayManager.session = [
    {
      manage = "desktop";
      name = "zsnes";
      start = ''
        ${pkgs.retroarchFull}/bin/retroarch --fullscreen &
        waitPID=$!
      '';
    }
  ];

  nixpkgs.overlays = [
    (self: super: {
      retroarchFull = super.retroarch.override {
        cores = [ super.libretro.snes9x2010 ];
      };
    })
  ];

  users.users.zsnes = {
    isNormalUser = true;
    extraGroups = [ "video" ];
  };
}
