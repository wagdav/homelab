{ config, ... }:

let
  consulAgent = "localhost:8500";

  listenAddress = config.services.prometheus.listenAddress;

  scrapeConfigs = [
    {
      job_name = "prometheus";
      static_configs = [
        {
          targets = [ listenAddress ];
        }
      ];
    }
    {
      job_name = "node";
      consul_sd_configs = [
        {
          server = consulAgent;
          services = [ "node-exporter" ];
        }
      ];
      static_configs = [
        {
          targets = [
            "wrt:9100"
          ];
        }
      ];
    }
    {
      job_name = "grafana";
      consul_sd_configs = [
        {
          server = consulAgent;
          services = [ "grafana" ];
        }
      ];
    }
    {
      job_name = "loki";
      consul_sd_configs = [
        {
          server = consulAgent;
          services = [ "loki" ];
        }
      ];
    }
    {
      job_name = "promtail";
      consul_sd_configs = [
        {
          server = consulAgent;
          services = [ "promtail" ];
        }
      ];
    }
    {
      job_name = "telegraf";
      consul_sd_configs = [
        {
          server = consulAgent;
          services = [ "telegraf" ];
        }
      ];
    }
  ];

in

{
  imports = [ ./consul-catalog.nix ];

  services.prometheus = {
    enable = true;
    inherit scrapeConfigs;
  };

  services.consul.catalog = [
    {
      name = "prometheus";
      port = 9090;
      tags = [
         "traefik.enable=true"
         "traefik.http.routers.prometheus1.rule=Host(`prometheus`)"
         "traefik.http.routers.prometheus2.rule=Host(`prometheus.thewagner.home`)"
      ];
    }
  ];

  networking.firewall.allowedTCPPorts = [ 9090 ];
}
