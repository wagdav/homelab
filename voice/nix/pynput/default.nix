{ buildPythonPackage, fetchPypi,

  setuptools-lint, sphinx, xlib
 }:

buildPythonPackage rec {
  pname = "pynput";
  version = "1.6.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "16h4wn7f54rw30jrya7rmqkx3f51pxn8cplid95v880md8yqdhb8";
  };

  propagatedBuildInputs = [
    setuptools-lint
    sphinx
    xlib
  ];

  doCheck = false;
}
