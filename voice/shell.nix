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

      MODEL_DIR=kaldi_model
      TMP_DIR="$MODEL_DIR".tmp

      if [ ! -d $MODEL_DIR ]; then
        rm -rf "$TMP_DIR"

        echo "Creating $MODEL_DIR in $(pwd)"
        cp -r ${kaldi-model} $MODEL_DIR
        find $MODEL_DIR -type f -exec chmod 644 {} \;
        find $MODEL_DIR -type d -exec chmod 755 {} \;
      else
        echo "Using $MODEL_DIR in $(pwd)"
      fi

      python \
        -m dragonfly load ${caster}/_*.py \
        --engine kaldi \
        --engine-options model_dir="$MODEL_DIR",tmp_dir="$TMP_DIR" \
        --no-recobs-messages \
        --log-level INFO
    }
  '';
}
