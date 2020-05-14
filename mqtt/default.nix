{ config, ... }:

let

  prometheus_client_port = 9883;

in

{
  imports = [ ../modules/consul-catalog.nix ];

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

  services.telegraf = {
    enable = true;

    extraConfig = {
      inputs.mqtt_consumer = {
        servers = [ "tcp://127.0.0.1:${toString config.services.mosquitto.port}" ];
        topics = [ "tele/+/SENSOR" ];
        data_format = "json";
      };

      outputs.prometheus_client = {
        listen = ":${toString prometheus_client_port}";
        metric_version = 2;
        export_timestamp = true;
        expiration_interval = "5m";
      };
    };
  };

  services.consul.catalog = [
    {
      name = "mosquitto";
      port = config.services.mosquitto.port;
    }
    {
      name = "telegraf";
      port = prometheus_client_port;
    }
  ];

  networking.firewall.allowedTCPPorts = [
    config.services.mosquitto.port
    prometheus_client_port
  ];
}
