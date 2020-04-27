let

  domain = "thewagner.home";

in

{
  network.description = "${domain} infrastructure";

  ipc = {
    imports = [
      ./hardware/ipc.nix
      ./common.nix
      ./prometheus/node-exporter.nix
      ./mqtt
      ./git
    ];

    services.nginx = {
      enable = true;

      gitweb = {
        enable = true;
        virtualHost = "git.${domain}";
      };

      virtualHosts = {
        "git" = {
          globalRedirect = "git.${domain}";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 ];
  };

  nuc = { config, ... } : {
    imports = [
      ./hardware/nuc.nix
      ./common.nix
      ./prometheus/server.nix
      ./prometheus/node-exporter.nix
      ./grafana
    ];

    services.nginx = let
      grafana = config.services.grafana;
      prometheus = config.services.prometheus;
    in {
      enable = true;

      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      virtualHosts = {
        "metrics" = {
          globalRedirect = "metrics.${domain}";
        };

        "metrics.${domain}" = {
          locations."/".proxyPass = "http://${grafana.addr}:${toString grafana.port}";
        };

        "prometheus" = {
          globalRedirect = "prometheus.${domain}";
        };

        "prometheus.${domain}" = {
          locations."/".proxyPass = "http://${prometheus.listenAddress}";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 ];
  };


  rp3 = { config, ...}: {
    imports = [
      ./hardware/rp3.nix
      ./common.nix
      ./prometheus/node-exporter.nix
    ];
  };
}
