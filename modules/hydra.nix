{ config, pkgs, ... }:
{
  imports = [
    ./consul-catalog.nix
    ./buildMachines.nix
  ];

  services.hydra = {
    enable = true;
    hydraURL = "http://hydra.thewagner.home";
    port = 3300;
    notificationSender = "hydra@localhost";
    buildMachinesFiles = [ ];
    useSubstitutes = true;
  };

  nix.buildMachines = [
    {
      hostName = "localhost";
      system = "x86_64-linux";
      supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
      maxJobs = 4;
    }
  ];

  services.consul.catalog = [
    {
      name = "hydra";
      port = config.services.hydra.port;
      tags = (import ./lib/traefik.nix).tagsForHost "hydra";
    }
  ];

  networking.firewall.allowedTCPPorts = [ config.services.hydra.port ];
}
