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

            (
              { pkgs, ... }: {
                nix.registry.nixpkgs.flake = nixpkgs;

                system.configurationRevision = revision;
              }
            )

            nixpkgs.nixosModules.notDetected
            nixos-hardware.nixosModules.lenovo-thinkpad-x230
          ];
      };

      nixopsConfigurations.default = {
        inherit nixpkgs;
      } // import ./home.nix { inherit revision; };

      defaultPackage.x86_64-linux = nixops.defaultPackage.x86_64-linux;

      checks.${system} = {
        nixpkgs-fmt = pkgs.runCommand "nixpkgs-fmt"
          {
            buildInputs = [ pkgs.nixpkgs-fmt ];
            src = builtins.path { path = ./.; name = "homelab-src"; };
          }
          ''
            mkdir $out
            nixpkgs-fmt --check "$src"
          '';

        markdownlint = pkgs.runCommand "mdl"
          {
            buildInputs = [ pkgs.mdl ];
          }
          ''
            mkdir $out
            mdl ${./README.md}
          '';

        yamllint = pkgs.runCommand "yamllint"
          {
            buildInputs = [ pkgs.yamllint ];
          }
          ''
            mkdir $out
            yamllint --strict ${./.github/workflows}
          '';
      };
    };
}
