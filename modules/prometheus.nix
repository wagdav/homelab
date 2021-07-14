{ config, ... }:
let
  consulAgent = "localhost:8500";

  scrapeConfigs = [
    {
      job_name = "consul";
      static_configs = [
        {
          targets = [
            "ipc:8500"
            "nuc:8500"
            "rp3:8500"
          ];
        }
      ];
      metrics_path = "/v1/agent/metrics";
      params.format = [ "prometheus" ];
    }
    {
      job_name = "consul_catalog";
      consul_sd_configs = [
        {
          server = consulAgent;
          services = [
            "grafana"
            "loki"
            "node-exporter"
            "prometheus"
            "promtail"
            "telegraf"
          ];
        }
      ];
    }
    {
      job_name = "node";
      static_configs = [
        {
          targets = [
            "wrt:9100"
          ];
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
      port = config.services.prometheus.port;
      tags = (import ./lib/traefik.nix).tagsForHost "prometheus";
    }
  ];

  networking.firewall.allowedTCPPorts = [ config.services.prometheus.port ];
}
