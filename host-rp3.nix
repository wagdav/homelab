{ config, nixos-hardware, ... }:

{
  imports = [
    nixos-hardware.nixosModules.raspberry-pi-3
    ./hardware/rp3.nix
    ./modules/cachix.nix
    #./modules/camera-rpi-v1
    ./modules/consul/client.nix
    ./modules/remote-builder
    ./modules/server.nix
    ./modules/vpn.nix
  ];

  system.stateVersion = "23.11";
}
