{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  programs.actionlint.enable = true;
  programs.nixpkgs-fmt.enable = true;
  programs.shellcheck.enable = true;
}
