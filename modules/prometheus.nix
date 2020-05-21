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
    }
  ];

  networking.firewall.allowedTCPPorts = [ 9090 ];
}
