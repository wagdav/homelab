{ config, pkgs, ... }:
let

  httpPort = 9080;

in
{
  imports = [ ./consul-catalog.nix ];

  services.promtail = {
    enable = true;
    configuration = {
      server.http_listen_port = httpPort;
      server.grpc_listen_port = 0;
      clients = [
        {
          url = "http://loki.thewagner.home/loki/api/v1/push";
        }
      ];

      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            path = "/var/log/journal";
            max_age = "12h";
            labels = {
              job = "systemd-journal";
            };
          };
          relabel_configs =
            [
              {
                source_labels = [ "__journal__systemd_unit" ];
                regex = "(.*)\\.service";
                target_label = "service";
              }
              {
                source_labels = [ "__journal__hostname" ];
                target_label = "hostname";
              }
            ];
        }
      ];
    };
  };

  services.consul.catalog = [
    {
      name = "promtail";
      port = httpPort;
    }
  ];

  networking.firewall.allowedTCPPorts = [ httpPort ];
}
