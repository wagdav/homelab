{ revision }:
{ config, ... }:

{
  imports = [
    ./hardware/rp3.nix
    (import ./modules/common.nix { inherit revision; })
    ./modules/remote-builder
  ];
}
