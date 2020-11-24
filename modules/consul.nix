{ config, ... }:

{
  services.consul = {
    enable = true;

    extraConfig = {
      server = true;
      retry_join = [ "ipc" "nuc" "rp3" ];
      bootstrap_expect = 3;

      client_addr = [ "0.0.0.0" ];

      telemetry = {
        disable_hostname = true;
        prometheus_retention_time = "2m";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8300 8301 8500 8600 ];
  networking.firewall.allowedUDPPorts = [ 8301 8600 ];
}
