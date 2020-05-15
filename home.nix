let

  domain = "thewagner.home";

in

{
  network.description = "${domain} infrastructure";

  ipc = {
    imports = [
      ./hardware/ipc.nix
      ./common.nix
      ./consul
      ./prometheus/node-exporter.nix
      ./modules/mqtt.nix
      ./modules/git.nix
    ];

    services.nginx = {
      enable = true;

      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

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
      ./consul
      ./modules/prometheus.nix
      ./prometheus/node-exporter.nix
      ./modules/grafana.nix
    ];

    services.nginx = let
      grafana = config.services.grafana;
      prometheus = config.services.prometheus;
    in {
      enable = true;

      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

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
      ./consul
      ./prometheus/node-exporter.nix
    ];
  };
}
