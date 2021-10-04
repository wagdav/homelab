{ config, ... }:

{
  imports = [
    ./hardware/nuc.nix
    ./modules/common.nix
    ./modules/consul.nix
    ./modules/grafana
    ./modules/hydra.nix
    ./modules/loki.nix
    ./modules/prometheus.nix
    ./modules/remote-builder
  ];
}
