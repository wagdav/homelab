{ buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "json-rpc";
  version = "1.13.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "12bmblnznk174hqg2irggx4hd3cq1nczbwkpsqqzr13hbg7xpw6y";
  };

  doCheck = false;
}
