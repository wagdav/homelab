{ stdenv
, fetchFromGitHub
, lib
, meson
, ninja
, pkg-config
, boost
, ffmpeg
, libcamera
, libdrm
, libepoxy
, libexif
, libjpeg
, libpng
, libtiff
, libX11
, qt5
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rpicam-apps";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "rpicam-apps";
    rev = "v${finalAttrs.version}";
    hash = "sha256-s4zJh6r3VhiquO54KWZ78dVCH1BmlphY9zEB9BidNyo=";
  };

  buildInputs = [
    boost
    ffmpeg
    libcamera
    libdrm
    libepoxy  # GLES/EGL preview window
    libexif
    libjpeg
    libpng
    libtiff
    libX11
    qt5.qtbase
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    qt5.wrapQtAppsHook
  ];

  # Meson is no longer able to pick up Boost automatically.
  # https://github.com/NixOS/nixpkgs/issues/86131
  BOOST_INCLUDEDIR = "${lib.getDev boost}/include";
  BOOST_LIBRARYDIR = "${lib.getLib boost}/lib";

  mesonFlags = [
    "-Denable_hailo=disabled"
    # maybe also disabled QT: "-Denable_qt=disabled"
    # See all options here: https://github.com/raspberrypi/rpicam-apps/blob/main/meson_options.txt
  ];

  meta = with lib; {
    description = "Small suite of libcamera-based apps that aim to copy the functionality of the existing 'raspicam' apps.";
    homepage = "https://github.com/raspberrypi/rpicam-apps";
    license = licenses.bsd2;
    maintainers = with maintainers; [ jpds ];
    platforms = platforms.linux;
  };
})
