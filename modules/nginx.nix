{ config, lib, pkgs, ... }:

let

  domain = "thewagner.home";

  consulService = {
    loki = "loki";
    metrics = "grafana";
    prometheus = "prometheus";
  };

in {

  services.nginx = {
    enable = true;

    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    gitweb = {
      enable = true;
      virtualHost = "git.${domain}";
      location = "";
    };

    virtualHosts = {
      "git" = {
        globalRedirect = "git.${domain}";
      };
    };

    appendHttpConfig = ''
      include /tmp/*-consul.conf;
    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  systemd.services.consul-template = let

    nginxTemplate = name: service : pkgs.writeText "${service}-consul.tmpl" ''
      upstream ${service} {
      {{ range service "${service}" }}
        server {{ .Address }}:{{ .Port }};
      {{ end }}
      }

      server {
        listen 0.0.0.0:80;
        listen [::]:80;
        server_name ${name};
        return 301 http://${name}.${domain}$request_uri;
      }

      server {
        listen 0.0.0.0:80;
        listen [::]:80;
        server_name ${name}.${domain};
        location / {
          proxy_pass http://${service};

          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Server $host;
          proxy_set_header Accept-Encoding "";
        }
      }
    '';

    toArg = name: service: (
      "-template " +
      "\"" +
      (builtins.concatStringsSep ":" [
        "${nginxTemplate name service}"
        "/tmp/${service}-consul.conf"
        "${pkgs.nginx}/bin/nginx -s reload"
      ]) +
      "\"");

  in {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    path = with pkgs; [ consul-template systemd ];

    serviceConfig = {
      ExecStart = (
        "${pkgs.consul-template}/bin/consul-template " +
        builtins.concatStringsSep " " (lib.mapAttrsToList toArg consulService)
      );
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      Restart = "on-failure";
      User = config.services.nginx.user;
      Group = config.services.nginx.group;
    };
  };
}
