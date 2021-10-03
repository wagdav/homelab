{ config, ... }:

let

  lokiWithGo116 = self: super: {
    grafana-loki = super.grafana-loki.override {
      buildGoModule = super.buildGo116Module;
    };
  };

in
{
  imports = [
    ./hardware/ipc.nix
    ./modules/common.nix
    ./modules/git.nix
    ./modules/mqtt.nix
    ./modules/traefik.nix
  ];

  nixpkgs.overlays = [ lokiWithGo116 ];
}
