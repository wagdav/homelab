{ config, pkgs, nixos-hardware, ... }:

{
  imports = [
    nixos-hardware.nixosModules.raspberry-pi-4
    ./hardware/rp4.nix
    ./modules/cachix.nix
    ./modules/consul/client.nix
    ./modules/remote-builder
    ./modules/server.nix
    ./modules/vpn.nix
  ];

  system.stateVersion = "23.11";

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree.enable = true;
  };

  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
}
