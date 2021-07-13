{ config, pkgs, ... }:
{
  imports = [ ./consul-catalog.nix ];

  services.hydra = {
    enable = true;
    hydraURL = "http://hydra.thewagner.home";
    port = 3300;
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [ ];
    useSubstitutes = true;
  };

  services.consul.catalog = [
    {
      name = "hydra";
      port = config.services.hydra.port;
      tags = (import ./lib/traefik.nix).tagsForHost "hydra";
    }
  ];

  networking.firewall.allowedTCPPorts = [ config.services.hydra.port ];

  nix.buildMachines = [
    {
      hostName = "localhost";
      system = "x86_64-linux";
      supportedFeatures = [
        "aarch64-linux"
        "benchmark"
        "big-parallel"
        "i686-linux"
        "kvm"
        "nixos-test"
        "x86_64-linux"
      ];
    }
  ];
}

