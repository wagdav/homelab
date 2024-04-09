{ config, ... }:

{
  services.consul = {
    enable = true;

    extraConfig = {
      retry_join = [ "nuc" ];

      client_addr = [ "0.0.0.0" ];

      telemetry = {
        disable_hostname = true;
        prometheus_retention_time = "2m";
      };

      disable_update_check = true;
    };
  };

  # https://www.consul.io/docs/install/ports
  networking.firewall.allowedTCPPorts = [ 8300 8301 8302 8500 8600 ];
  networking.firewall.allowedUDPPorts = [ 8301 8302 8600 ];
}
