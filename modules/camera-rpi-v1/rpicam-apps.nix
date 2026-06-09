# Based on https://github.com/NixOS/nixpkgs/pull/281803
{ stdenv
, fetchFromGitHub
, lib
, makeWrapper
, meson
, ninja
, pkg-config
, boost
, ffmpeg-headless
, libcamera
, libdrm
, libepoxy
, libexif
, libjpeg
, libpng
, libtiff
, libX11
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rpicam-apps";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "rpicam-apps";
    rev = "v${finalAttrs.version}";
    hash = "sha256-u/VdAHCiXlc9MDHcVG2DPKqnQGEynlXIieHuAkcTarQ=";
  };

  buildInputs = [
    boost
    ffmpeg-headless
    libcamera
    libdrm
    libepoxy # GLES/EGL preview window
    libexif
    libjpeg
    libpng
    libtiff
    libX11
  ];

  nativeBuildInputs = [
    makeWrapper
    meson
    ninja
    pkg-config
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=deprecated-declarations"
  ];

  # See all options here: https://github.com/raspberrypi/rpicam-apps/blob/main/meson_options.txt
  mesonFlags = [
    "-Denable_drm=disabled"
    "-Denable_egl=disabled"
    "-Denable_hailo=disabled"
    "-Denable_qt=disabled"
  ];

  postInstall = ''
    for f in rpicam-hello rpicam-jpeg rpicam-raw rpicam-still rpicam-vid
    do
      wrapProgram $out/bin/$f --set-default LIBCAMERA_IPA_PROXY_PATH ${libcamera}/libexec/libcamera
    done
  '';
})
