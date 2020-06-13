{ buildPythonPackage, fetchFromGitHub,

  appdirs, dragonfly2, future, mock, numpy, pillow, scandir, tkinter, tomlkit,
  wxPython_4_0
}:

buildPythonPackage rec {
  pname = "caster";
  version = "bd1f07cb04a3f288a597a8aed7f784ab99eba7fc";

  src = fetchFromGitHub {
    owner = "dictation-toolbox";
    repo = pname;
    rev = version;
    sha256 = "1gniryvhwbxf0l98dmc3aycr6y5c5z2jfb2sky20jsdr6m01w2ln";
  };

  propagatedBuildInputs = [
    appdirs
    dragonfly2
    future
    mock
    numpy
    pillow
    scandir
    tkinter
    tomlkit
    wxPython_4_0
  ];

  postInstall = ''
    cp _*.py $out
  '';

  doCheck = false;
}
