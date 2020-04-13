# To build the installer for your system's architecture:
#
#   nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix
#
# To build a 32-bit installer, overrride the value of the `system` parameter:
#
#   nix-build <SAME AS BEFORE> --argStr system i686-linux
#

{ config, pkgs, system ? builtins.currentSystem, ... }:

{
  imports = [
    # https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keyFiles = [ ~/.ssh/id_rsa.pub ];
  };

  environment.etc = {
    "install.sh" = {
      source = ./install.sh;
      mode = "0700";
    };

    "configuration.nix" = {
      source = ./configuration.nix;
      mode = "0600";
    };
  };
}
