{ config, ... }:

{
  users = {
    # The private part of this key is manually provisioned in
    #
    #   /root/remote-builder
    #
    # See the configuration option `nix.buildMachines.sshKey` in x230.nix
    users.root.openssh.authorizedKeys.keyFiles = [ ./remote-builder.pub ];
  };
}
