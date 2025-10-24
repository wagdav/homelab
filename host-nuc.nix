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

  containers.borrow = {
    autoStart = true;
    macvlans = [ "eno1" ];

    allowedDevices = [
      { node = "/dev/dri/card1"; modifier = "rw"; }
      { node = "/dev/dri/renderD128"; modifier = "rw"; }
    ];

    bindMounts = {
      "/dev/dri/card1" = {
        hostPath = "/dev/dri/card1";
        isReadOnly = false;
      };
      "/dev/dri/renderD128" = {
        hostPath = "/dev/dri/renderD128";
        isReadOnly = false;
      };
    };

    config =
      { config, lib, pkgs, ... }:
      {
        imports = [
          ./modules/media.nix
          ./modules/vpn.nix
        ];

        networking.useDHCP = lib.mkForce true;
        networking.useHostResolvConf = lib.mkForce false; # Workaround for https://github.com/NixOS/nixpkgs/issues/162686
        services.resolved.enable = true;
        system.stateVersion = "24.05";
      };
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
        networking.useHostResolvConf = lib.mkForce false; # Workaround for https://github.com/NixOS/nixpkgs/issues/162686
        services.resolved.enable = true;
        system.stateVersion = "24.05";
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
          ./modules/vpn.nix
        ];
        networking.useDHCP = lib.mkForce true;
        networking.useHostResolvConf = lib.mkForce false; # Workaround for https://github.com/NixOS/nixpkgs/issues/162686
        services.resolved.enable = true;
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
