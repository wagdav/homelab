{ config, ... }:

{
  imports = [
    ./hardware/rp3.nix
    ./modules/common.nix
    ./modules/consul/server.nix
    ./modules/remote-builder
  ];
}
