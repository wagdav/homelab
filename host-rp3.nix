{ config, ... }:

{
  imports = [
    ./hardware/rp3.nix
    ./modules/common.nix
    ./modules/remote-builder
  ];

  system.stateVersion = "22.05";
}
