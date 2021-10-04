{ config, ... }:

{
  imports = [
    ./hardware/rp3.nix
    ./modules/common.nix
    ./modules/consul.nix
    ./modules/remote-builder
  ];
}
