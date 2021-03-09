{ config, pkgs, ... }:
let
  httpPort = 9080;

  configFile = pkgs.writeText "promtail-config.yaml" ''
    server:
      http_listen_port: ${toString httpPort}
      grpc_listen_port: 0

    positions:
      filename: /tmp/positions.yaml

    clients:
      - url: http://loki.thewagner.home/loki/api/v1/push

    scrape_configs:
    - job_name: journal
      journal:
        path: /var/log/journal
        max_age: 12h
        labels:
          job: systemd-journal
      relabel_configs:
       - source_labels: ['__journal__systemd_unit' ]
         target_label: 'unit'
       - source_labels: ['__journal__hostname']
         target_label: 'hostname'
  '';

in
{
  imports = [ ./consul-catalog.nix ];

  systemd.services.promtail = {
    description = "Promtail service for Loki";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.grafana-loki}/bin/promtail --config.file ${configFile}
      '';
      User = "promtail";
      Group = "promtail";
    };
  };

  users.groups.promtail = { };
  users.users.promtail = {
    description = "Promtail Service User";
    group = "promtail";
    extraGroups = [ "systemd-journal" ];
    isSystemUser = true;
  };

  services.consul.catalog = [
    {
      name = "promtail";
      port = httpPort;
    }
  ];

  networking.firewall.allowedTCPPorts = [ httpPort ];
}
