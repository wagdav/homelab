{ revision }:
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
    (import ./modules/common.nix { inherit revision; })
    ./modules/git.nix
    ./modules/mqtt.nix
    ./modules/traefik.nix
  ];

  nixpkgs.overlays = [ lokiWithGo116 ];
}
