{ config, ... }:

{
  fileSystems = {
    "/mnt/nas" = {
      device = "dns-320.local:/mnt/HD/HD_a2/Ajaxpf";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "_netdev" ];
    };
  };
}
