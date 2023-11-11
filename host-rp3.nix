{ config, ... }:

{
  imports = [
    ./hardware/rp3.nix
    ./modules/common.nix
    ./modules/cachix.nix
    ./modules/remote-builder
    ./modules/consul/client.nix
  ];

  system.stateVersion = "23.11";
}
