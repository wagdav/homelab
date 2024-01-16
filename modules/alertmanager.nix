{ config, ... }:

{
  imports = [ ./consul-catalog.nix ];

  services.prometheus.alertmanager = {
    enable = true;
    configuration = {
      route.receiver = "webhook";
      receivers = [
        {
          name = "webhook";
          webhook_configs = [
            {
              url = "http://localhost:${toString config.services.webhook.port}/hooks/alertmanager";
            }
          ];
        }
      ];
    };
  };

  services.consul.catalog = [
    {
      name = "alertmanager";
      port = config.services.prometheus.alertmanager.port;
      tags = (import ./lib/traefik.nix).tagsForHost "alertmanager";
      check = {
        name = "Health endpoint";
        http = "http://localhost:${toString config.services.prometheus.alertmanager.port}/-/healthy";
        interval = "10s";
      };
    }
  ];

  networking.firewall.allowedTCPPorts = [ config.services.prometheus.alertmanager.port ];
}
