{ config, ... }:

{
  imports = [ ./consul-catalog.nix ];

  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "cpu" "filesystem" "loadavg" "systemd" ];
    disabledCollectors = [ "rapl" ];
    extraFlags = [
      "--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"
    ];
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

  system.activationScripts.node-exporter-system-version = ''
    mkdir -pm 0775 /var/lib/prometheus-node-exporter-text-files
    (
      cd /var/lib/prometheus-node-exporter-text-files
      (
        echo -n "nixos_system_version ";
        readlink /nix/var/nix/profiles/system | cut -d- -f2
      ) > system-version.prom.next
      mv system-version.prom.next system-version.prom
    )
  '';
}
