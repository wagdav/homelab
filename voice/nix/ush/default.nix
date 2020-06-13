{ buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "ush";
  version = "3.1.0";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    sha256 = "1d5ms7jnvkspsi2avsqc6di0ga725mq0zgyi91gfrqz7av6pl7i4";
  };
}
