{ config, lib, pkgs, ... }:

{
  imports = [
    ./node-exporter.nix
    ./promtail.nix
  ];

  documentation.enable = false;

  environment.systemPackages = with pkgs; [
    vim
  ];

  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keys = (import ./keys.nix).dwagner;
  };
}
