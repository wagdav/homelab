{
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  inputs.nixops.url = "github:NixOS/nixops";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  inputs.cachix-deploy.url = "github:cachix/cachix-deploy-flake";

  outputs = { self, flake-compat, nixpkgs, nixops, nixos-hardware, cachix-deploy }:
    let
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};

      cachix-deploy-lib = cachix-deploy.lib pkgs;

      revision = "latest";

      defaults = {
        nix.registry.nixpkgs.flake = nixpkgs;
        system.configurationRevision = revision;
      };

      mkMachine = system: modules: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = modules ++ [ defaults ];
      };

      mqtt-dash-listen = pkgs.writeScriptBin "mqtt-dash-listen" ''
        echo 1>&2 "Press Publish Metrics in the MQTT Dash app..."
        ${pkgs.mosquitto}/bin/mosquitto_sub -h mqtt -t 'metrics/exchange' -C 1 | ${pkgs.jq}/bin/jq -r .
      '';

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
              }

              nixpkgs.nixosModules.notDetected
              nixos-hardware.nixosModules.lenovo-thinkpad-x230
            ];
        };

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

        network.storage.memory = { };

        nuc = ./host-nuc.nix;
        rp3 = ./host-rp3.nix;
        rp4 = {
          imports = [
            ./host-rp4.nix
            nixos-hardware.nixosModules.raspberry-pi-4
          ];
        };
      };

      apps.${system}.mqtt-dash-listen = {
        type = "app";
        program = "${mqtt-dash-listen}/bin/mqtt-dash-listen";
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ nixops.defaultPackage.${system} ];
      };

      packages.${system} = with pkgs; {
        sensors = callPackage ./nodemcu/provision.nix { };
        cachix-deploy-spec = cachix-deploy-lib.spec {
          agents = {
            nuc = self.nixosConfigurations.nuc.config.system.build.toplevel;
          };
        };
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
        x86_64-linux = {
          nuc = self.nixosConfigurations.nuc.config.system.build.toplevel;
          x230 = self.nixosConfigurations.x230.config.system.build.toplevel;
        };

        aarch64-linux = {
          rp3 = self.nixosConfigurations.rp3.config.system.build.toplevel;
          rp4 = self.nixosConfigurations.rp4.config.system.build.toplevel;
        };
      };
    };
}
