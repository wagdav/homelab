{ config, pkgs, ... }:

let

  name = "nuc";

in

{
  imports = [
     <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ./common.nix
  ];

  deployment.targetHost = "${name}.thewagner.home";
  networking.hostName = name;

  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.wlp58s0.useDHCP = true;
}
