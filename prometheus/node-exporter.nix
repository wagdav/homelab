{ config, ... }:

{
  imports = [ ../modules/consul-catalog.nix ];

  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "cpu" "filesystem" "loadavg" "systemd" ];
  };

  networking.firewall.allowedTCPPorts = [
    config.services.prometheus.exporters.node.port
  ];

  services.consul.catalog = [
    {
      name = "node-exporter";
      port = config.services.prometheus.exporters.node.port;
    }
  ];
}
