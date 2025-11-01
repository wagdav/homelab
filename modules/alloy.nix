{ config, pkgs, ... }:
{
  services.alloy = {
    enable = true;
  };

  environment.etc."alloy/logs.alloy".text = ''
    loki.relabel "journal" {
      forward_to = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        regex = "(.*)\\.service"
        target_label = "service"
      }

      rule {
        source_labels = ["__journal__hostname"]
        target_label  = "hostname"
      }
    }

    loki.source.journal "read"  {
      forward_to    = [loki.write.endpoint.receiver]
      relabel_rules = loki.relabel.journal.rules
      labels        = {component = "loki.source.journal"}
    }

    loki.write "endpoint" {
      endpoint {
        url = "http://nuc:3100/loki/api/v1/push"
      }
    }
  '';
}

