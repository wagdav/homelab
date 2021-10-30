{ config, pkgs, ... }:

{
  imports = [
    ./hardware/rp4.nix
    ./modules/common.nix
    ./modules/consul/client.nix
    ./modules/kodi.nix
    ./modules/remote-builder
  ];
}
