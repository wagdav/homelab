{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.03";

  outputs = { self, nixpkgs }: {

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
  };
}
