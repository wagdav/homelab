{ config, lib, pkgs, ... }:
let

  name = "nuc";

in
{
  nix.settings.max-jobs = lib.mkDefault 4;

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
  };

  systemd.network = {
    enable = true;

    netdevs."25-mv-0" = {
      netdevConfig = {
        Name = "mv-0";
        Kind = "macvlan";
      };
      macvlanConfig.Mode = "bridge";
    };

    networks."30-wired" = {
      matchConfig = {
        Name = "eno1";
      };
      linkConfig.RequiredForOnline = "carrier";
      networkConfig = {
        MACVLAN = "mv-0";
        DHCP = "no";
        IPv6AcceptRA = false;
        LinkLocalAddressing = false;
        MulticastDNS = false;
        LLMNR = false;
      };
    };

    networks."35-mv-0" = {
      matchConfig = {
        Name = "mv-0";
      };
      linkConfig.RequiredForOnline = "routable";
      networkConfig = {
        BindCarrier = "eno1";
        DHCP = "yes";
      };
    };
  };
}
