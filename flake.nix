{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
  inputs.nixops.url = "github:NixOS/nixops/flake-support";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  outputs = { self, nixpkgs, nixops, nixos-hardware }: {

    nixosConfigurations.x230 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          ./x230.nix

          (
            { pkgs, ... }: {
              nix.registry.nixpkgs.flake = nixpkgs;

              system.configurationRevision = (self.rev or "dirty");
            }
          )

          nixpkgs.nixosModules.notDetected
          nixos-hardware.nixosModules.lenovo-thinkpad-x230
        ];
    };

    nixopsConfigurations.default = {
      inherit nixpkgs;
    } // import ./home.nix { revision = self.rev or "dirty"; };

    defaultPackage.x86_64-linux = nixops.defaultPackage.x86_64-linux;
  };
}
