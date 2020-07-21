{ config, ...}:

{
  imports = [ ./consul-catalog.nix ];

  services.grafana = {
    enable = true;
    addr = "0.0.0.0";
    auth.anonymous.enable = true;
    auth.anonymous.org_role = "Viewer";

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
          url = "http://nuc.thewagner.home:3100";
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.grafana.port ];

  services.consul.catalog = [
    {
      name = "grafana";
      port = config.services.grafana.port;
    }
  ];
}
