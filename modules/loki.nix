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
      tags = (import ./lib/traefik.nix).tagsForHost "loki";
    }
  ];

  networking.firewall.allowedTCPPorts = [ httpPort ];
}
