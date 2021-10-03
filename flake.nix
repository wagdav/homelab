{
  inputs.neovim.url = "github:neovim/neovim?dir=contrib";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  inputs.nixops.url = "github:NixOS/nixops";
  inputs.nixops.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  outputs = { self, neovim, nixpkgs, nixops, nixos-hardware }:
    let
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};

      revision = "latest";
    in
    {
      nixosConfigurations = {
        ipc = nixpkgs.lib.nixosSystem {
          system = "i686-linux";
          modules = [
            (import ./host-ipc.nix { inherit revision; })
            {
              nix.registry.nixpkgs.flake = nixpkgs;
            }
          ];
        };

        nuc = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (import ./host-nuc.nix { inherit revision; })
            {
              nix.registry.nixpkgs.flake = nixpkgs;
            }
          ];
        };

        rp3 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            (import ./host-rp3.nix { inherit revision; })
            {
              nix.registry.nixpkgs.flake = nixpkgs;
            }
          ];
        };

        x230 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules =
            [
              ./x230.nix

              {
                nix.registry.nixpkgs.flake = nixpkgs;

                system.configurationRevision = revision;

                programs.neovim.package = neovim.defaultPackage.x86_64-linux;
              }

              nixpkgs.nixosModules.notDetected
              nixos-hardware.nixosModules.lenovo-thinkpad-x230
            ];
        };
      };

      nixopsConfigurations.default = {
        inherit nixpkgs;
      } // import ./home.nix { inherit revision; };


      devShell.${system} = pkgs.mkShell {
        buildInputs = [ nixops.defaultPackage.${system} ];
      };

      packages.${system} = with pkgs; {
        sensors = callPackage ./nodemcu/provision.nix { };
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

      hydraJobs = {
        ipc = self.nixosConfigurations.ipc.config.system.build.toplevel;
        nuc = self.nixosConfigurations.nuc.config.system.build.toplevel;
        rp3 = self.nixosConfigurations.rp3.config.system.build.toplevel;
        x230 = self.nixosConfigurations.x230.config.system.build.toplevel;
      };
    };
}
