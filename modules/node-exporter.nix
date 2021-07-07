{ config, ... }:

{
  imports = [ ./consul-catalog.nix ];

  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "cpu" "filesystem" "loadavg" "systemd" ];
    disabledCollectors = [ "rapl" ];
    extraFlags = [ "--collector.textfile.directory=/etc/metrics" ];
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

  environment.etc."metrics/revision.prom".text = ''
    node_nixos_configuration{revision="${config.system.configurationRevision}"} 1
  '';
}
