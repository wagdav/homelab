{ config, ... }:

{
  imports = [
    ./hardware/nuc.nix
    ./modules/alertmanager.nix
    ./modules/cachix.nix
    ./modules/consul/server.nix
    ./modules/git.nix
    ./modules/grafana
    ./modules/loki.nix
    ./modules/mqtt.nix
    ./modules/prometheus.nix
    ./modules/push-notifications.nix
    ./modules/remote-builder
    ./modules/server.nix
    ./modules/traefik.nix
    ./modules/vpn.nix
    ./modules/webhook.nix
  ];

  services.tailscale = {
    useRoutingFeatures = "server";
    extraUpFlags = "--advertise-exit-node";
  };

  system.stateVersion = "22.05";
}
