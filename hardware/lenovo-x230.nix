let
  revision = "a78b8b647692919fe871f5726b7b5e01dd725a88";
  sha256 = "0lcfj18wbi4a7nv6fc1pvq28m210laviy00d4dngklrppihykj40";

  nixos-hardware = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixos-hardware/archive/${revision}.tar.gz";
    inherit sha256;
  };

in
(import "${nixos-hardware}/lenovo/thinkpad/x230")
