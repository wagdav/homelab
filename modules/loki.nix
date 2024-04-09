{ config, pkgs, ... }:
let
  httpPort = 3100;

  # https://grafana.com/docs/loki/latest/configuration/examples/#complete-local-config
  configuration = {
    auth_enabled = false;

    server.http_listen_port = httpPort;
    server.log_level = "warn";

    ingester = {
      lifecycler = {
        address = "127.0.0.1";
        ring = {
          kvstore.store = "inmemory";
          replication_factor = 1;
        };
        final_sleep = "0s";
      };
      chunk_idle_period = "5m";
      chunk_retain_period = "30s";
    };

    schema_config = {
      configs = [
        {
          from = "2020-05-15";
          store = "boltdb";
          object_store = "filesystem";
          schema = "v11";
          index = {
            prefix = "index_";
            period = "168h";
          };
        }
      ];
    };

    storage_config = {
      boltdb.directory = "/tmp/loki/index";
      filesystem.directory = "/tmp/loki/chunks";
    };

    limits_config = {
      enforce_metric_name = false;
      reject_old_samples = true;
      reject_old_samples_max_age = "168h";
    };

    ruler = {
      storage = {
        type = "local";
        local.directory = "/tmp/rules";
      };
      rule_path = "/tmp/scratch";
      alertmanager_url = "http://nuc:9093";
      ring.kvstore.store = "inmemory";
      enable_api = true;
    };

    query_scheduler = {
      max_outstanding_requests_per_tenant = 2048;
    };
  };

in
{
  imports = [ ./consul-catalog.nix ];

  services.loki = {
    enable = true;
    inherit configuration;
  };

  services.consul.catalog = [
    {
      name = "loki";
      port = httpPort;
      tags = (import ./lib/traefik.nix).tagsForHost "loki";
    }
  ];

  networking.firewall.allowedTCPPorts = [ httpPort ];
}
