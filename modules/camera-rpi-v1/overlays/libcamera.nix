final: prev: {
  libcamera = prev.libcamera.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ prev.boost prev.nlohmann_json ];
    nativeBuildInputs = old.nativeBuildInputs ++ [ prev.python3Packages.pybind11 ];

    BOOST_INCLUDEDIR = "${prev.lib.getDev prev.boost}/include";
    BOOST_LIBRARYDIR = "${prev.lib.getLib prev.boost}/lib";

    postPatch = old.postPatch + ''
      patchShebangs src/py/libcamera
    '';

    mesonFlags = old.mesonFlags ++ [
      "-Dcam=disabled"
      "-Dgstreamer=disabled"
      "-Dipas=rpi/vc4,rpi/pisp"
      "-Dpipelines=rpi/vc4,rpi/pisp"
    ];

    src = prev.fetchFromGitHub {
      owner = "raspberrypi";
      repo = "libcamera";
      rev = "f0e40f1c50bd0afe65727d6e407d0dcb42666ada";
      sha256 = "sha256-sJKzmeeXD/66P5o+X9w3J2gwxDNsdBUdXEqU6goJdN4=";

      nativeBuildInputs = [ prev.git ];

      postFetch = ''
        cd "$out"

        export NIX_SSL_CERT_FILE=${prev.cacert}/etc/ssl/certs/ca-bundle.crt

        ${prev.lib.getExe prev.meson} subprojects download \
          libpisp

        find subprojects -type d -name .git -prune -execdir rm -r {} +
      '';
    };
  });
}
