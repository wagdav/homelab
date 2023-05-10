{ fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "dashboard-linter";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "dashboard-linter";
    rev = "b1f5eb2cca53b30525eeca68d65e5ba017e90df2";
    sha256 = "0a1gf6y5vlyrbhmqsgqh91s74wp2saylaqr3rmag7yjhjpi4s4gq";
  };

  vendorHash = "sha256-BRe+I1tZZw0YXLhidLbapIrqP55vuSx/gSADLW0PXL0=";

  meta = {
    description = " A tool to lint Grafana dashboards ";
    homepage = "https://github.com/grafana/dashboard-linter";
  };
}
