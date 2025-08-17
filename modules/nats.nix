{ config, ... }:

{
  services.nats = {
    enable = true;
    jetstream = true;
    settings = {
      mqtt = {
        port = 1883;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.nats.port 1883 ];
}
