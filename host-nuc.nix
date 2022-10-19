{ config, ... }:

{
  imports = [
    ./hardware/nuc.nix
    ./modules/cachix.nix
    ./modules/common.nix
    ./modules/consul/server.nix
    ./modules/git.nix
    ./modules/grafana
    ./modules/loki.nix
    ./modules/mqtt.nix
    ./modules/prometheus.nix
    ./modules/remote-builder
    ./modules/traefik.nix
    ./modules/vpn.nix
  ];

  system.stateVersion = "22.05";
}
