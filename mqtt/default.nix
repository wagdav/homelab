{ config, ... }:

{
  services.mosquitto = {
    enable = true;
    host = "0.0.0.0";
    users = { };

    allowAnonymous = true;

    # Also listen on all IPv6 interfaces
    extraConf = ''
      listener ${toString config.services.mosquitto.port} ::
    '';

    aclExtraConf = ''
      topic readwrite #

      user david
      topic owntracks/david/#
    '';
  };

  networking.firewall.allowedTCPPorts = [ config.services.mosquitto.port ];
}
