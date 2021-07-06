{ revision }:
{ config, ... }:

{
  imports = [
    ./hardware/nuc.nix
    (import ./modules/common.nix { inherit revision; })
    ./modules/grafana
    ./modules/loki.nix
    ./modules/prometheus.nix
    ./modules/remote-builder
  ];
}
