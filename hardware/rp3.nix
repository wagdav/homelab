# Raspberry Pi 3
{ config, lib, pkgs, ... }:
let

  name = "rp3";

in
{
  nix.settings.max-jobs = lib.mkDefault 4;
  nixpkgs.system = "aarch64-linux";

  boot = {
    initrd.kernelModules = [ "vc4" "bcm2835_dma" "i2c_bcm2835" ];
    loader = {
      grub.enable = false;

      raspberryPi = {
        enable = true;
        uboot.enable = true;
        version = 3;
      };
    };
  };

  networking.wireless = {
    enable = true;
    environmentFile = "/etc/secrets/wireless.env";
    networks."@WIFI_SSID@".psk = "@WIFI_KEY@";
    interfaces = [ "wlan0" ];
  };

  hardware.enableRedistributableFirmware = true;

  environment.systemPackages = with pkgs; [
    libraspberrypi
  ];

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
