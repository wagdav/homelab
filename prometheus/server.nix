{ config, ... }:

let
  listenAddress = config.services.prometheus.listenAddress;

  nodePort = config.services.prometheus.exporters.node.port;

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
      static_configs = [
        {
          targets = [
            "ipc:${toString nodePort}"
            "nuc:${toString nodePort}"
            "rp3:${toString nodePort}"
            "wrt:${toString nodePort}"
          ];
        }
      ];
    }
    {
      job_name = "grafana";
      static_configs = [
        {
          targets = [ "metrics.thewagner.home" ];
        }
      ];
    }
    {
      job_name = "telegraf";
      static_configs = [
        {
          targets = [ "ipc:9883" ];
        }
      ];
    }
  ];

in

{
  services.prometheus = {
    enable = true;
    inherit scrapeConfigs;
  };
}
