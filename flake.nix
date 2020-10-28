{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";

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

    devShell.x86_64-linux = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ nixops.overlay ];
      };

      in pkgs.mkShell {
        buildInputs = [ pkgs.nixops ];
      };
  };
}
