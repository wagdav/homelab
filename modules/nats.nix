{ config, ... }:

{
  services.nats = {
    enable = true;
    jetstream = true;
    settings = {
      http_port = 8222;
      mqtt = {
        port = 1883;
      };
      websocket = {
        port = 8080;
        no_tls = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.nats.port 1883 8080 8222 ];
}
