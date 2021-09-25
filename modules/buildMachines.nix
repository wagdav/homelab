{ config, lib, ... }:

{
  programs.ssh.knownHosts = {
    nuc = {
      hostNames = [ "nuc" "nuc.thewagner.home" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKaEtc8PNqhxAQ24gY5t25Y/8HU6StUB6kmU1xmVta7";
    };

    rp3 = {
      hostNames = [ "rp3" "rp3.thewagner.home" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILK0illQrUbCmn+UHgM79tDecSItLUVNuWi/Sg+DW2tr";
    };
  };

  nix = {
    distributedBuilds = true;
    buildMachines =
      let
        sshUser = "root";
        sshKey = "/root/remote-builder";
        domain = "thewagner.home";
      in
      lib.filter (m: m.hostName != "${config.networking.hostName}.${domain}") [
        {
          hostName = "nuc.${domain}";
          systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
          maxJobs = 4;
          supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
          inherit sshUser sshKey;
        }
        {
          hostName = "rp3.${domain}";
          system = "aarch64-linux";
          maxJobs = 4;
          supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
          inherit sshUser sshKey;
        }
      ];
  };
}
