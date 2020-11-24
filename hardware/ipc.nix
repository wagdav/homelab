# 32-bit Lannert industrial PC
{ config, lib, pkgs, ... }:

let

  name = "ipc";

in

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  deployment.targetHost = name;
  nixpkgs.system = "i686-linux";
  nix.maxJobs = lib.mkDefault 2;

  boot = {
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "ehci_pci"
        "sd_mod"
        "uhci_hcd"
        "usbhid"
        "usb_storage"
      ];

      kernelModules = [];
    };

    kernelModules = [];

    extraModulePackages = [];

    # Use the GRUB 2 boot loader.
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  networking = {
    hostName = name;

    useDHCP = false;

    interfaces = {
      enp1s0.useDHCP = true;
      enp2s0.useDHCP = true;
    };
  };
}
