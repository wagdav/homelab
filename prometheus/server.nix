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
  ];

in

{
  services.prometheus = {
    enable = true;
    inherit scrapeConfigs;
  };
}
