# Raspberry Pi 4
{ config, lib, pkgs, ... }:
let

  name = "rp4";

in
{
  nixpkgs.system = "aarch64-linux";

  services.journald.extraConfig = ''
    Storage = volatile
    RuntimeMaxFileSize = 10M
  '';

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

  hardware = {
    pulseaudio.enable = true;
  };

  networking = {
    hostName = name;
  };

  networking.wireless = {
    enable = true;
    secretsFile = "/etc/secrets/wireless.env";
    networks."Eat-Knit-Code-Repeat".pskRaw = "ext:WIFI_KEY";
    interfaces = [ "wlan0" ];
  };
}
