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
    raspberry-pi."4".bluetooth.enable = true;
    deviceTree.enable = true;
    enableAllFirmware = true;
  };

  # enableAllFirmware + bluetooth pull in unfree Broadcom firmware, and the
  # vc4-kms-v3d overlay below comes from the unfree raspberrypifw package.
  nixpkgs.config.allowUnfree = true;

  # Full ("real") KMS. nixos-hardware's raspberry-pi-4 module only offers *fake*
  # KMS (raspberry-pi."4".fkms-3d.enable), where the firmware owns the display
  # and CEC is reachable only through /dev/vchiq. Full KMS hands the HDMI
  # pipeline to the vc4 kernel driver, which exposes the standard kernel CEC
  # device /dev/cec0 (used by modules/jellyfin-tv.nix) and is the
  # upstream-supported path — fake KMS is deprecated.
  #
  # config.txt overlays can't do this here: U-Boot loads the generation's device
  # tree via extlinux's FDTDIR, bypassing config.txt. So we merge the overlay
  # into the generation DTB ourselves, using the Pi-4 variant the firmware itself
  # loads for `dtoverlay=vc4-kms-v3d` on a Pi 4.
  hardware.deviceTree = {
    filter = "bcm2711-rpi-4*.dtb";
    overlays = [
      {
        # Reserve 512 MiB CMA for the KMS framebuffers.
        name = "rpi4-cma-overlay";
        dtsText = ''
          /dts-v1/;
          /plugin/;
          / {
            compatible = "brcm,bcm2711";
            fragment@0 {
              target = <&cma>;
              __overlay__ {
                size = <(512 * 1024 * 1024)>;
              };
            };
          };
        '';
      }
      {
        name = "vc4-kms-v3d-pi4";
        dtboFile = "${pkgs.raspberrypifw}/share/raspberrypi/boot/overlays/vc4-kms-v3d-pi4.dtbo";
      }
    ];
  };

  # Full KMS exposes a DRM device; use the modesetting driver for X.
  services.xserver.videoDrivers = lib.mkBefore [ "modesetting" "fbdev" ];

  boot.kernelParams = [ "snd_bcm2835.enable_hdmi=1" ];

  boot.kernelModules = [ "hidp" ];
}
