{ config, ...}:

{
  services.grafana = {
    enable = true;
    addr = "0.0.0.0";
    auth.anonymous.enable = true;
    auth.anonymous.org_role = "Viewer";

    provision = {
      enable = true;
      datasources = [
        {
          name = "Prometheus";
          isDefault = true;
          type = "prometheus";
          url = "http://nuc:9090";  # FIXME: remove hard-coded Prometheus port
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    config.services.grafana.port
  ];
}
