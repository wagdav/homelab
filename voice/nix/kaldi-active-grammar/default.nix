{ buildPythonPackage, fetchPypi,

  autoPatchelfHook, pythonManylinuxPackages,

  cffi, numpy, requests, six, ush
}:

buildPythonPackage rec {
  pname = "kaldi_active_grammar";
  version = "1.4.0";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    platform = "manylinux2010_x86_64";
    sha256 = "0p37ib3paaqvp5kqad7zk6qs6ba31lyac10xg63wzzlr2hy9hv3c";
  };

  dontStrip = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    pythonManylinuxPackages.manylinux2010
  ];

  propagatedBuildInputs = [
    cffi
    numpy
    requests
    six
    ush
  ];

  doCheck = false;
}
