{ config, lib, ... }:

{
  services.consul = {
    enable = true;

    extraConfig = {
      bind_addr = "{{ GetPrivateInterfaces | include \"network\" \"192.168.1.0/24\" | attr \"address\" }}";

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

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "consul"
  ];
}
