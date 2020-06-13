{ pkgs ? import ./nix/nixpkgs.nix }:

with pkgs.python3Packages;

let
  json-rpc = callPackage ./nix/json-rpc { };

  setuptools-lint = callPackage ./nix/setuptools-lint { };

  pynput = callPackage ./nix/pynput {
    inherit setuptools-lint;
  };

  ush = callPackage ./nix/ush { };

  caster = callPackage ./nix/caster {
    inherit dragonfly2;
  };

  dragonfly2 = callPackage ./nix/dragonfly2 {
    inherit pynput json-rpc kaldi-active-grammar;
  };

  kaldi-active-grammar = callPackage ./nix/kaldi-active-grammar {
    inherit ush;
  };

  kaldi-model =  callPackage ./nix/kaldi-model { };

in

pkgs.mkShell {
  buildInputs = with pkgs; [
    caster
    xclip
    xdotool
  ];

  shellHook = ''
    dragonfly() {
      set -eu

      MODEL=kaldi_model

      if [ ! -d $MODEL ]; then
        rm -rf "$MODEL.tmp"

        echo "Creating $MODEL in $(pwd)"
        cp -r ${kaldi-model} $MODEL
        find $MODEL -type f -exec chmod 644 {} \;
        find $MODEL -type d -exec chmod 755 {} \;
      else
        echo "Using $MODEL in $(pwd)"
      fi

      python \
        -m dragonfly load ${caster}/_*.py \
        --engine kaldi \
        --no-recobs-messages \
        --log-level INFO
    }
  '';
}
