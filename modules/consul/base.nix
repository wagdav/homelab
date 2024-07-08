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

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "consul"
  ];
}
