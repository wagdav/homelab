{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
  inputs.nixops.url = "github:NixOS/nixops/flake-support";
  inputs.nixops.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  outputs = { self, nixpkgs, nixops, nixos-hardware }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };

      revision = "${self.lastModifiedDate}-${self.shortRev or "dirty"}";
    in
    {
      nixosConfigurations.x230 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules =
          [
            ./x230.nix

            {
              nix.registry.nixpkgs.flake = nixpkgs;

              system.configurationRevision = revision;
            }

            nixpkgs.nixosModules.notDetected
            nixos-hardware.nixosModules.lenovo-thinkpad-x230
          ];
      };

      nixopsConfigurations.default = {
        inherit nixpkgs;
      } // import ./home.nix { inherit revision; };


      devShell.${system} = pkgs.mkShell {
        buildInputs = [ nixops.defaultPackage.${system} ];
      };

      checks.${system} = with pkgs; {
        nixpkgs-fmt = runCommand "nixpkgs-fmt"
          {
            buildInputs = [ nixpkgs-fmt ];
            src = self;
          }
          ''
            mkdir $out
            nixpkgs-fmt --check "$src"
          '';

        markdownlint = runCommand "mdl"
          {
            buildInputs = [ mdl ];
          }
          ''
            mkdir $out
            mdl ${./README.md}
          '';

        shellcheck = runCommand "shellcheck"
          {
            buildInputs = [ shellcheck ];
          }
          ''
            mkdir $out
            shellcheck --shell bash ${./scripts}/*
          '';

        yamllint = runCommand "yamllint"
          {
            buildInputs = [ yamllint ];
          }
          ''
            mkdir $out
            yamllint --strict ${./.github/workflows}
          '';
      };
    };
}
