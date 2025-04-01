{ config, ... }:

{
  services.nats = {
    enable = true;
    jetstream = true;
  };

  networking.firewall.allowedTCPPorts = [ config.services.nats.port ];
}
