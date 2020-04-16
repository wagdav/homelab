{
  network.description = "thewagner.home infrastructure";

  ipc = {
    imports = [
      ./ipc.nix
      ./common.nix
      ./prometheus/node-exporter.nix
    ];
  };

  nuc = {
    imports = [
      ./nuc.nix
      ./common.nix
      ./prometheus/server.nix
      ./prometheus/node-exporter.nix
      ./grafana
    ];
  };
}
