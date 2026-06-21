{ config, pkgs, ... }:

{
  imports = [ ../consul-catalog.nix ];

  systemd.services.grafana-renderer-token = {
    description = "Generate Grafana Renderer Token";
    before = [ "grafana.service" ];
    requiredBy = [ "grafana.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /var/lib/grafana-tokens
      chmod 700 /var/lib/grafana-tokens

      if [ ! -f /var/lib/grafana-tokens/renderer_token ]; then
        ${pkgs.pwgen}/bin/pwgen -s -1 32 | ${pkgs.coreutils}/bin/tr -d '\n' > /var/lib/grafana-tokens/renderer_token
        chmod 400 /var/lib/grafana-tokens/renderer_token
      fi
    '';
  };

  systemd.services.grafana = {
    serviceConfig.LoadCredential = "renderer_token:/var/lib/grafana-tokens/renderer_token";
  };

  services.grafana = {
    enable = true;
    settings.server.http_addr = "0.0.0.0";
    settings."auth.anonymous" = {
      enabled = true;
      org_role = "Editor";
    };
    settings.security.secret_key = "SW2YcwTIb9zpOOhoPsMm"; # See https://nixos.org/manual/nixos/stable/release-notes#sec-release-26.05
    settings.rendering.renderer_token = "$__file{/run/credentials/grafana.service/renderer_token}";

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          isDefault = true;
          type = "prometheus";
          url = "http://nuc:9090";
        }
        {
          name = "Loki";
          type = "loki";
          url = "http://nuc:3100";
        }
        {
          name = "Alertmanager";
          type = "alertmanager";
          url = "http://nuc:9093";
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
    settings.server.addr = "0.0.0.0:8081";
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
    8081
  ];

  services.consul.catalog = [
    {
      name = "grafana";
      port = config.services.grafana.settings.server.http_port;
      tags = (import ../lib/traefik.nix).tagsForHost "metrics";
    }
    {
      name = "grafana-image-renderer";
      port = 8081;
    }
  ];
}
