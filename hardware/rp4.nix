# Raspberry Pi 4
{ config, lib, pkgs, ... }:
let

  name = "rp4";

in
{
  nixpkgs.system = "aarch64-linux";

  environment.systemPackages = with pkgs; [
    libraspberrypi
  ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

  hardware = {
    pulseaudio.enable = true;

    raspberry-pi."4".fkms-3d.enable = true;
    raspberry-pi."4".audio.enable = true;
  };

  networking = {
    hostName = name;
    networkmanager.enable = true;
  };

  nixpkgs.overlays = [
    (self: super: {
      libcec = super.libcec.override { inherit (super) libraspberrypi; };
    })
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="vchiq",GROUP="video",MODE="0660"
  '';
}
