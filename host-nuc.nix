{ config, ... }:

{
  imports = [
    ./hardware/nuc.nix
    ./modules/alertmanager.nix
    ./modules/backup.nix
    ./modules/cachix.nix
    ./modules/consul/server.nix
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

  containers.git = {
    autoStart = true;
    macvlans = [ "eno1" ];
    bindMounts = {
      "/srv/git" = {
        hostPath = "/srv/git";
        isReadOnly = false;
      };
    };
    config =
      { config, lib, ... }:
      {
        imports = [
          ./modules/git.nix
          ./modules/vpn.nix
        ];
        networking.useDHCP = lib.mkForce true;
        system.stateVersion = "24.05";
        services.tailscale.interfaceName = "userspace-networking";
      };
  };

  containers.nats = {
    autoStart = true;
    macvlans = [ "eno1" ];
    config =
      { config, lib, ... }:
      {
        imports = [
          ./modules/nats.nix
        ];
        networking.useDHCP = lib.mkForce true;
        system.stateVersion = "24.05";
      };
  };

  services.borgbackup.jobs.git = {
    paths = "/srv/git";
    repo = "borg@nuc:.";
    environment = { BORG_RSH = "ssh -i /root/keys/id_ed25519-borg-git"; };
    encryption.mode = "none";
    doInit = false;
    startAt = "daily";
    prune.keep = {
      within = "1d";
      daily = 7;
      weekly = 4;
      monthly = 12;
      yearly = 10;
    };
  };

  system.stateVersion = "22.05";
}
