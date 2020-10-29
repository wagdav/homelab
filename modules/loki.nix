{ config, pkgs, ... }:

let

  httpPort = 3100;

in

{
  imports = [ ./consul-catalog.nix ];

  services.loki = {
    enable = true;
    configFile = ''
      ${pkgs.grafana-loki.src}/cmd/loki/loki-local-config.yaml
    '';
  };

  services.consul.catalog = [
    {
      name = "loki";
      port = httpPort;
      tags = [
         "traefik.enable=true"
         "traefik.http.routers.loki1.rule=Host(`loki`)"
         "traefik.http.routers.loki2.rule=Host(`loki.thewagner.home`)"
      ];
    }
  ];

  networking.firewall.allowedTCPPorts = [ httpPort ];
}
