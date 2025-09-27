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

  networking = {
    hostName = name;
  };

  networking.wireless = {
    enable = true;
    secretsFile = "/etc/secrets/wireless.env";
    networks."Eat-Knit-Code-Repeat".pskRaw = "ext:WIFI_KEY";
    interfaces = [ "wlan0" ];
  };

  hardware = {
    raspberry-pi."4".fkms-3d.enable = true;
    raspberry-pi."4".bluetooth.enable = true;
    deviceTree.enable = true;
    enableAllFirmware = true;
  };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
  boot.kernelParams = [ "snd_bcm2835.enable_hdmi=1" ];

  boot.kernelModules = [ "hidp" ];
}
