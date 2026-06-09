final: prev: {
  libcamera = prev.libcamera.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ prev.elfutils prev.libpisp prev.libtiff ];

    mesonFlags = old.mesonFlags ++ [
      "-Dcam=disabled"
      "-Dgstreamer=disabled"
      "-Dipas=rpi/vc4,rpi/pisp"
      "-Dpipelines=rpi/vc4,rpi/pisp"
      "-Drpi-awb-nn=disabled"
    ];

    src = prev.fetchFromGitHub {
      owner = "raspberrypi";
      repo = "libcamera";
      rev = "v0.7.1+rpt20260609";
      sha256 = "sha256-qSCaAW5WuHcdg+i6YVLEF0rj3uM0Usw+I+hjde7yWvQ=";
    };
  });
}
