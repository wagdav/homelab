{ config, pkgs, ... }:

{
  nixpkgs.overlays = [ (import ../overlays/libcamera.nix) ];

  environment.systemPackages = with pkgs; [
    (callPackage ../rpicam-apps.nix { })
    libcamera
  ];
}
