{ config, lib, pkgs, ... }:

{
  imports = [
    ./alloy.nix
    ./node-exporter.nix
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
