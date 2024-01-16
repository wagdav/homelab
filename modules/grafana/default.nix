{ config, ... }:

{
  imports = [ ../consul-catalog.nix ];

  services.grafana = {
    enable = true;
    settings.server.http_addr = "0.0.0.0";
    settings."auth.anonymous" = {
      enabled = true;
      org_role = "Editor";
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          isDefault = true;
          type = "prometheus";
          url = "http://prometheus.thewagner.home";
        }
        {
          name = "Loki";
          type = "loki";
          url = "http://loki.thewagner.home";
        }
        {
          name = "Alertmanager";
          type = "alertmanager";
          url = "http://alertmanager.thewagner.home";
          jsonData.implementation = "prometheus";
          jsonData.handleGrafanaManagedAlerts = true;
        }
      ];

      dashboards.settings.providers = [
        {
          options.path = "/etc/dashboards";
        }
      ];
    };
  };

  services.grafana-image-renderer = {
    enable = true;
    provisionGrafana = true;
    settings.service.metrics.enabled = true;
  };

  # Provision each dashboard in /etc/dashboard
  environment.etc = builtins.mapAttrs
    (
      name: _: {
        target = "dashboards/${name}";
        source = ./. + "/dashboards/${name}";
      }
    )
    (builtins.readDir ./dashboards);

  networking.firewall.allowedTCPPorts = [
    config.services.grafana.settings.server.http_port
    config.services.grafana-image-renderer.settings.service.port
  ];

  services.consul.catalog = [
    {
      name = "grafana";
      port = config.services.grafana.settings.server.http_port;
      tags = (import ../lib/traefik.nix).tagsForHost "metrics";
    }
    {
      name = "grafana-image-renderer";
      port = config.services.grafana-image-renderer.settings.service.port;
    }
  ];
}
