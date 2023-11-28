# Raspberry Pi 3
{ config, lib, pkgs, ... }:
let

  name = "rp3";

in
{
  nix.settings.max-jobs = lib.mkDefault 4;
  nixpkgs.system = "aarch64-linux";

  boot = {
    kernelModules = [ "bcm2835-v4l2" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
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
