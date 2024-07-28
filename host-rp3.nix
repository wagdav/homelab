{ config, nixos-hardware, ... }:

{
  imports = [
    nixos-hardware.nixosModules.raspberry-pi-3
    ./hardware/rp3.nix
    ./modules/camera.nix
    ./modules/common.nix
    ./modules/cachix.nix
    ./modules/remote-builder
    ./modules/consul/client.nix
    ./modules/vpn.nix
  ];

  system.stateVersion = "23.11";
}
