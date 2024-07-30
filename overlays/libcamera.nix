final: prev: {
  libcamera = prev.libcamera.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ prev.boost prev.nlohmann_json ];
    nativeBuildInputs = old.nativeBuildInputs ++ [ prev.python3Packages.pybind11 ];

    BOOST_INCLUDEDIR = "${prev.lib.getDev prev.boost}/include";
    BOOST_LIBRARYDIR = "${prev.lib.getLib prev.boost}/lib";

    postPatch = old.postPatch + ''
      patchShebangs src/py/libcamera
    '';

    mesonFlags = prev.mesonFlags + [
      "-Dcam=disabled"
      "-Dgstreamer=disabled"
      "-Dipas=rpi/vc4,rpi/pisp"
      "-Dpipelines=rpi/vc4,rpi/pisp"
    ];

    src = prev.fetchFromGitHub {
      owner = "raspberrypi";
      repo = "libcamera";
      rev = "6ddd79b5bdbedc1f61007aed35391f1559f9e29a";
      sha256 = "eFIiYCsuukPuG6iqHZeKsXQYSuZ+9q5oLNwuJJ+bAhk=";

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
