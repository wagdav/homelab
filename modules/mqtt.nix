{ config, ... }:
let

  prometheus_client_port = 9883;
  mqtt_port = 1883;

in
{
  imports = [ ./consul-catalog.nix ];

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };

  services.telegraf = {
    enable = true;

    extraConfig = {
      inputs.mqtt_consumer = {
        servers = [ "tcp://127.0.0.1:${toString mqtt_port}" ];
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
      port = mqtt_port;
    }
    {
      name = "telegraf";
      port = prometheus_client_port;
    }
  ];

  networking.firewall.allowedTCPPorts = [
    mqtt_port
    prometheus_client_port
  ];
}
