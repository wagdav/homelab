# Raspberry Pi 3
{ config, lib, pkgs, ... }:
let

  name = "rp3";

in
{
  nix.maxJobs = lib.mkDefault 4;
  nixpkgs.system = "aarch64-linux";

  boot = {
    kernelPackages = pkgs.linuxPackages_5_4;
    initrd = {
      availableKernelModules = [
        "bcm2835_dma"
        "i2c_bcm2835"
        "usbhid"
        "vc4"
      ];
      kernelModules = [ ];
    };

    kernelParams = [ "cma=32M" ];

    extraModulePackages = [ ];

    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;

    loader.raspberryPi = {
      enable = true;
      uboot.enable = true;
      version = 3;
    };
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
  ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

  networking = {
    hostName = name;

    useDHCP = false;

    interfaces = {
      eth0.useDHCP = true;
      wlan0.useDHCP = true;
    };
  };
}
