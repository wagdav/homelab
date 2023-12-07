{ config, pkgs, ... }:

{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "http://nuc";
      listen-http = ":8080";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];

  users.users = {
    ntfy = {
      isSystemUser = true;
      group = "ntfy";
    };
  };

  users.groups."ntfy" = { };

  systemd.services."send-room-humidity" = {
    path = [ pkgs.curl ];
    script = ''
      set -eu
      ${../scripts/push-room-humidity.sh}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "ntfy";
    };
  };

  systemd.timers."send-room-humidity" = {
    wantedBy = [ "timers.target" ];
    after = [ "network-online.target" ];
    timerConfig = {
      OnCalendar = [ "*-*-*  8:00" "*-*-* 22:00" ];
      Unit = "send-room-humidity.service";
    };
  };
}
