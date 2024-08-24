{ config, lib, ... }:

{
  programs.ssh.knownHosts = {
    nuc = {
      hostNames = [ "nuc" "nuc.thewagner.home" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKaEtc8PNqhxAQ24gY5t25Y/8HU6StUB6kmU1xmVta7";
    };

    rp3 = {
      hostNames = [ "rp3" "rp3.thewagner.home" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7PpM3BlMNoiS1RtdAPPktucd2USaYaifLaE5Hd63RA";
    };

    rp4 = {
      hostNames = [ "rp4" "rp4.thewagner.home" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/z/WxE1OsrpXsv+NtHv5jkZtKRF9RtrFGVZyXWzMhm";
    };
  };

  nix = {
    distributedBuilds = true;
    buildMachines =
      let
        sshUser = "root";
        sshKey = "/root/remote-builder";
      in
      lib.filter (m: m.hostName != "${config.networking.hostName}") [
        {
          hostName = "nuc";
          systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
          maxJobs = 4;
          supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
          inherit sshUser sshKey;
        }
        {
          hostName = "rp4";
          systems = [ "aarch64-linux" ];
          maxJobs = 2;
          supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
          inherit sshUser sshKey;
          speedFactor = 2;
        }
      ];
  };
}
