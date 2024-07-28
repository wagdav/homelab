# Raspberry Pi 3
{ config, lib, pkgs, ... }:
let

  name = "rp3";

in
{
  nix.settings.max-jobs = lib.mkDefault 4;
  nixpkgs.system = "aarch64-linux";

  networking.wireless = {
    enable = true;
    environmentFile = "/etc/secrets/wireless.env";
    networks."@WIFI_SSID@".psk = "@WIFI_KEY@";
    interfaces = [ "wlan0" ];
  };

  hardware.enableRedistributableFirmware = true;

  services.journald.extraConfig = ''
    Storage = volatile
    RuntimeMaxFileSize = 10M
  '';

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

  networking = {
    hostName = name;
  };
}
