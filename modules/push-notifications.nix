{ config, ... }:

{
  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = ":8080";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
