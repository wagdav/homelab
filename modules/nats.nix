{ config, ... }:

{
  services.nats = {
    enable = true;
    jetstream = true;
    settings = {
      mqtt = {
        port = 1883;
      };
      websocket = {
        port = 8080;
        no_tls = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.nats.port 1883 8080 ];
}
