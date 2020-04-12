{ config, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "cpu" "filesystem" "loadavg" "systemd" ];
  };

  networking.firewall.allowedTCPPorts = [
    config.services.prometheus.exporters.node.port
  ];
}
