let

  domain = "thewagner.home";

in

{
  network.description = "${domain} infrastructure";

  ipc = {
    imports = [
      ./hardware/ipc.nix
      ./modules/common.nix
      ./modules/consul.nix
      ./modules/git.nix
      ./modules/mqtt.nix
      ./modules/node-exporter.nix
      ./modules/nginx.nix
      ./modules/promtail.nix
    ];

  };

  nuc = {
    imports = [
      ./hardware/nuc.nix
      ./modules/common.nix
      ./modules/consul.nix
      ./modules/grafana.nix
      ./modules/loki.nix
      ./modules/node-exporter.nix
      ./modules/prometheus.nix
      ./modules/promtail.nix
    ];
  };

  rp3 = {
    imports = [
      ./hardware/rp3.nix
      ./modules/common.nix
      ./modules/consul.nix
      ./modules/node-exporter.nix
      ./modules/promtail.nix
    ];
  };
}
