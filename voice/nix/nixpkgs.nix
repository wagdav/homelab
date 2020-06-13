let
  # Channel nixos-20.03
  # See the hash from at https://status.nixos.org/
  revision = "8b071be7512bd2cd0ff5c3bdf60f01ab4eb94abd";
  sha256 = "079rzd17y2pk48kh70pbp4a7mh56vi2b49lzd365ckh38gdv702z";

  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${revision}.tar.gz";
    inherit sha256;
  };

in

  (import nixpkgs {})
