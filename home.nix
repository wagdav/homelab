{
  network.description = "thewagner.home infrastructure";

  ipc = import ./ipc.nix;
  nuc = import ./nuc.nix;
}
