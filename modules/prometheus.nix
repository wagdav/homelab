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
      params.format = ["prometheus"];
    }
    {
      job_name = "prometheus";
      consul_sd_configs = [
        {
          server = consulAgent;
          services = [ "prometheus" ];
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
      tags = (import ./lib/traefik.nix).tagsForHost "prometheus";
    }
  ];

  networking.firewall.allowedTCPPorts = [ 9090 ];
}
