{ config, ... }:

let

  user = "git";
  group = "gitolite";

in

{
  services = {
    gitolite = {
      enable = true;
      adminPubkey = builtins.readFile ~/.ssh/id_rsa.pub;

      inherit user group;
    };

    gitweb = {
      projectroot = "${config.services.gitolite.dataDir}/repositories";
    };

    nginx.gitweb = { inherit group; };
  };
}
