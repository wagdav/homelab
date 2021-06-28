{ revision }:
let

  lokiWithGo116 = self: super: {
    grafana-loki = super.grafana-loki.override {
      buildGoModule = super.buildGo116Module;
    };
  };

in
{
  network.description = "My home infrastructure";

  defaults = {
    imports = [
      ./modules/common.nix
      ./modules/consul.nix
      ./modules/node-exporter.nix
      ./modules/promtail.nix

      {
        system.configurationRevision = revision;
      }
    ];
  };

  ipc = {
    imports = [
      ./hardware/ipc.nix
      ./modules/git.nix
      ./modules/mqtt.nix
      ./modules/traefik.nix

      (
        { config, ... }:
        {
          nixpkgs.overlays = [ lokiWithGo116 ];
        }
      )
    ];

  };

  nuc = {
    imports = [
      ./hardware/nuc.nix
      ./modules/grafana
      ./modules/loki.nix
      ./modules/prometheus.nix
      ./modules/remote-builder
    ];
  };

  rp3 = {
    imports = [
      ./hardware/rp3.nix
      ./modules/remote-builder
    ];
  };
}
