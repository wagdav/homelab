{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
  inputs.nixops.url = "github:NixOS/nixops/flake-support";

  outputs = { self, nixpkgs, nixops }: {

    nixosConfigurations.x230 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          ./x230.nix

          ({ pkgs, ... }: {
            nix.registry.nixpkgs.flake = nixpkgs;
          })

          nixpkgs.nixosModules.notDetected
        ];
    };

    nixopsConfigurations.default = {
      inherit nixpkgs;
    } // import ./home.nix;

    defaultPackage.x86_64-linux = nixops.defaultPackage.x86_64-linux;
  };
}
