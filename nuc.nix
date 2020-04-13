{ config, lib, pkgs, ... }:

let

  name = "nuc";

in

{
  imports = [
     <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ./common.nix
  ];

  deployment.targetHost = "${name}.thewagner.home";
  networking.hostName = name;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.wlp58s0.useDHCP = true;

  nix.maxJobs = lib.mkDefault 4;
}
