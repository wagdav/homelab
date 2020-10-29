{ config, lib, pkgs, ... }:

{

  services.traefik = {
    enable = true;
    staticConfigOptions = {
      providers.consulCatalog = {
        exposedByDefault = false;
        prefix = "traefik";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}

