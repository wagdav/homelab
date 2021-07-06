{ revision }:
{
  network.description = "My home infrastructure";

  ipc = import ./host-ipc.nix { inherit revision; };
  nuc = import ./host-nuc.nix { inherit revision; };
  rp3 = import ./host-rp3.nix { inherit revision; };
}
