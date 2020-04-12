# 32-bit Lannert industrial PC
{ config, lib, pkgs, ... }:

let

  name = "ipc";

in

{
  imports = [
     <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ./common.nix
    ./prometheus/node-exporter.nix
  ];

  deployment.targetHost = "${name}.thewagner.home";
  networking.hostName = name;
  nixpkgs.system = "i686-linux";

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.interfaces.enp2s0.useDHCP = true;

  nix.maxJobs = lib.mkDefault 2;
}
