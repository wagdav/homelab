{ lib, ... }:

{
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

  nix.maxJobs = lib.mkDefault 4;

  i18n.defaultLocale = "en_US.UTF-8";

  services.nixosManual.showManual = false;
  services.openssh.enable = true;
  services.openssh.allowSFTP = false;
  services.openssh.passwordAuthentication = false;

  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keyFiles = [ ~/.ssh/id_rsa.pub ];
  };
}
