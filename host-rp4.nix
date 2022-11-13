{ config, pkgs, ... }:

{
  imports = [
    ./hardware/rp4.nix
    ./modules/arcade.nix
    ./modules/common.nix
    ./modules/consul/client.nix
    ./modules/remote-builder
  ];

  system.stateVersion = "22.05";
}
