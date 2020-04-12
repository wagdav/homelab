{ config, ... }:

let

  listenPort = 9090;

  nodePort = config.services.prometheus.exporters.node.port;

  grafana = config.services.grafana;

  scrapeConfigs = [
    {
      job_name = "prometheus";
      static_configs = [
        {
          targets = [ "127.0.0.1:${toString listenPort}" ];
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
          targets = [ "nuc:${toString grafana.port}" ];
        }
      ];
    }
  ];

in

{
  services.prometheus = {
    enable = true;
    listenAddress = "0.0.0.0:${toString listenPort}";
    inherit scrapeConfigs;
  };

  networking.firewall.allowedTCPPorts = [
    listenPort
  ];
}
