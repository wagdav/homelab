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
        topics = [ "tele/+/SENSOR" "tele/+/STATE" ];
        data_format = "json";
        json_string_fields = [ "POWER" ];
        topic_parsing = [
          {
            topic = "tele/+/+";
            fields = "_/device/_";
          }
        ];
      };

      processors.enum = [
        {
          mapping = [
            {
              field = "POWER";
              value_mappings = {
                ON = 1;
                OFF = 0;
              };
            }
          ];
        }
        {
          mapping = [
            {
              field = "device";
              dest = "room";
              value_mappings = {
                "tasmota_082320" = "Living room";
                "tasmota_0E63DE" = "Bedroom";
                "tasmota_96804E" = "Living room";
                "tasmota_D892EA" = "Study";
                "tasmota_D8A2DD" = "Kitchen";
              };
            }
          ];
        }
      ];

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
