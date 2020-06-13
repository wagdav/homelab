{ buildPythonPackage, fetchPypi,
  decorator, json-rpc, kaldi-active-grammar, lark-parser, psutil, pynput,
  pyperclip, regex, sounddevice, webrtcvad, werkzeug,
}:

buildPythonPackage rec {
  pname = "dragonfly2";
  version = "0.24.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "08a4x3zh1889hdf6pv99nk36x5bxdvg7rqy90r7jz46yiijxzh8l";
  };

  propagatedBuildInputs = [
    decorator
    json-rpc
    lark-parser
    psutil
    pynput
    pyperclip
    regex
    werkzeug
  ]
  ++ # Extras Kaldi
  [
    kaldi-active-grammar
    sounddevice
    webrtcvad
  ];

  doCheck = false;
}
