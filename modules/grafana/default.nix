{ config, ... }:

{
  imports = [ ../consul-catalog.nix ];

  services.grafana = {
    enable = true;
    addr = "0.0.0.0";
    auth.anonymous.enable = true;
    auth.anonymous.org_role = "Editor";

    provision = {
      enable = true;
      datasources = [
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
      ];

      dashboards = [
        {
          options.path = "/etc/dashboards";
        }
      ];
    };
  };

  # Provision each dashboard in /etc/dashboard
  environment.etc = builtins.mapAttrs (
    name: _: {
      target = "dashboards/${name}";
      source = builtins.path { path = ./dashboards; inherit name; };
    }
  ) (builtins.readDir ./dashboards);

  networking.firewall.allowedTCPPorts = [ config.services.grafana.port ];

  services.consul.catalog = [
    {
      name = "grafana";
      port = config.services.grafana.port;
      tags = (import ../lib/traefik.nix).tagsForHost "metrics";
    }
  ];
}
