/**
  Derivation that exposes the source code of the application
*/
{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  name = "app-src";

  src = ./. + "../../src"; # This forces the source to be in the flake directory in nix store

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/src
    cp -r $src/* $out/share/src
  '';
}
