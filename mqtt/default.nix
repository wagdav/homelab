{ config, ... }:

{
  services.mosquitto = {
    enable = true;
    host = "0.0.0.0";
    users = { };

    allowAnonymous = true;
    aclExtraConf = ''
      topic readwrite #

      user david
      topic owntracks/david/#
    '';
  };

  networking.firewall.allowedTCPPorts = [ config.services.mosquitto.port ];
}
