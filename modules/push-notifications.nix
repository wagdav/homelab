{ config, ... }:

{
  services.ntfy-sh = {
    enable = true;
    settings = {
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

  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 9,12,22 * * * ntfy . ${../scripts/push-room-humidity.sh} >> /tmp/cron-ntfy.log 2>&1"
    ];
  };
}
