{ config, pkgs, ... }:

let

  command = pkgs.writeShellScriptBin "ntfy" ''
    externalUrl=$1
    status=$2
    summary=$3
    description=$4

    if [ "$status" = "firing" ]; then
      icon=rotating_light
    else
      icon=tada
    fi

    ${pkgs.curl}/bin/curl \
      -H "X-Tags: $icon" \
      -H "Title: $summary" \
      -H "Click: $externalUrl" \
      -d "$description" \
      "http://nuc:8080/home-thewagner-ec1"
  '';

in

{
  imports = [ ./consul-catalog.nix ];

  services.webhook = {
    enable = true;
    hooks = {
      alertmanager = {
        execute-command = "${command}/bin/ntfy";
        incoming-payload-content-type = "application/json";
        pass-arguments-to-command = [
          {
            source = "payload";
            name = "externalURL";
          }
          {
            source = "payload";
            name = "alerts.0.status";
          }
          {
            source = "payload";
            name = "alerts.0.annotations.summary";
          }
          {
            source = "payload";
            name = "alerts.0.annotations.description";
          }
        ];
      };
    };
  };

  services.consul.catalog = [
    {
      name = "webhook";
      port = config.services.webhook.port;
      tags = (import ./lib/traefik.nix).tagsForHost "webhook";
    }
  ];

  networking.firewall.allowedTCPPorts = [ config.services.webhook.port ];
}
