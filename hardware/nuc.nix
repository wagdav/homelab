{ config, lib, pkgs, ... }:
let

  name = "nuc";

in
{
  deployment.targetHost = name;
  nix.maxJobs = lib.mkDefault 4;

  boot = {
    initrd = {
      availableKernelModules = [
        "ahci"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "usb_storage"
        "xhci_pci"
      ];

      kernelModules = [ ];
    };

    kernelModules = [ "kvm-intel" ];

    extraModulePackages = [ ];

    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  fileSystems = {
    "/boot" =
      {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
      };

    "/" =
      {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  networking = {
    hostName = name;
    useDHCP = false;

    interfaces = {
      eno1.useDHCP = true;
      wlp58s0.useDHCP = true;
    };
  };
}
