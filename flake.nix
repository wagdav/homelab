{
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.cachix-deploy.url = "github:cachix/cachix-deploy-flake";
  inputs.nixos-generators = {
    url = "github:nix-community/nixos-generators";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, disko, flake-compat, nixpkgs, nixos-generators, nixos-hardware, cachix-deploy }@attrs:
    let
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};

      cachix-deploy-lib = cachix-deploy.lib pkgs;

      revision = "${self.lastModifiedDate}-${self.shortRev or "dirty"}";

      defaults = {
        nix.registry.nixpkgs.flake = nixpkgs;
      };

      mkMachine = system: modules: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = modules ++ [ defaults ];
        specialArgs = attrs;
      };

      mqtt-dash-listen = pkgs.writeScriptBin "mqtt-dash-listen" ''
        echo 1>&2 "Press Publish Metrics in the MQTT Dash app..."
        ${pkgs.mosquitto}/bin/mosquitto_sub -h mqtt -t 'metrics/exchange' -C 1 | ${pkgs.jq}/bin/jq -r .
      '';

      dashboard-linter = pkgs.callPackage ./modules/grafana/dashboard-linter.nix { };

    in
    {
      nixosConfigurations = {
        x1 = mkMachine "x86_64-linux" [ ./x1.nix ];
        x230 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules =
            [
              ./x230.nix

              {
                nix.registry.nixpkgs.flake = nixpkgs;
              }

              nixpkgs.nixosModules.notDetected
              nixos-hardware.nixosModules.lenovo-thinkpad-x230
            ];
        };

        nuc = mkMachine "x86_64-linux" [ ./host-nuc.nix ];
        rp3 = mkMachine "aarch64-linux" [ ./host-rp3.nix ];
        rp4 = mkMachine "aarch64-linux" [ ./host-rp4.nix ];
      };

      apps.${system} = {
        mqtt-dash-listen = {
          type = "app";
          program = "${mqtt-dash-listen}/bin/mqtt-dash-listen";
        };

        dashboard-linter = {
          type = "app";
          program = "${dashboard-linter}/bin/dashboard-linter";
        };
      };

      packages.${system} = with pkgs; {
        sensors = callPackage ./nodemcu/provision.nix { };
        cachix-deploy-spec = cachix-deploy-lib.spec {
          agents = {
            nuc = self.nixosConfigurations.nuc.config.system.build.toplevel;
            x230 = self.nixosConfigurations.x230.config.system.build.toplevel;
            rp3 = self.nixosConfigurations.rp3.config.system.build.toplevel;
            rp4 = self.nixosConfigurations.rp4.config.system.build.toplevel;
          };
        };
      };

      packages.aarch64-linux = {
        sdcard = nixos-generators.nixosGenerate {
          system = "aarch64-linux";
          format = "sd-aarch64";
          specialArgs = attrs;
          modules = [ ./host-rp3.nix ];
        };

        sdcard-rp4 = nixos-generators.nixosGenerate {
          system = "aarch64-linux";
          format = "sd-aarch64";
          specialArgs = attrs;
          modules = [ ./host-rp4.nix ];
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
            buildInputs = [ actionlint yamllint ];
          }
          ''
            mkdir $out
            yamllint --strict ${./.github/workflows}
            # actionlint ${./.github/workflows}/*.yml
          '';
      };
    };
}
