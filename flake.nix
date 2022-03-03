{
  inputs.neovim.url = "github:neovim/neovim/838631e29ef3051d6117b3d5c340d2be9f1f29b4?dir=contrib";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  inputs.nixops.url = "github:NixOS/nixops";
  inputs.nixops.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

  outputs = { self, neovim, nixpkgs, nixops, nixos-hardware }:
    let
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};

      revision = "latest";

      defaults = {
        nix.registry.nixpkgs.flake = nixpkgs;
        system.configurationRevision = revision;
      };

      mkMachine = system: modules: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = modules ++ [ defaults ];
      };
    in
    {
      nixosConfigurations = {
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

        ipc = mkMachine "i686-linux" [ ./host-ipc.nix ];
        nuc = mkMachine "x86_64-linux" [ ./host-nuc.nix ];
        rp3 = mkMachine "aarch64-linux" [ ./host-rp3.nix ];
        rp4 = mkMachine "aarch64-linux" [
          ./host-rp4.nix
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      };

      nixopsConfigurations.default = {
        inherit defaults nixpkgs;

        network.description = "My home infrastructure";

        network.storage.legacy = {
          databasefile = "~/.nixops/deployments.nixops";
        };

        ipc = ./host-ipc.nix;
        nuc = ./host-nuc.nix;
        rp3 = ./host-rp3.nix;
        rp4 = {
          imports = [
            ./host-rp4.nix
            nixos-hardware.nixosModules.raspberry-pi-4
          ];
        };
      };

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
        rp4 = self.nixosConfigurations.rp4.config.system.build.toplevel;
        x230 = self.nixosConfigurations.x230.config.system.build.toplevel;
      };
    };
}
