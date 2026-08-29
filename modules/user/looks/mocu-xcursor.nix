{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  librsvg,
  xmlstarlet,
  xcursorgen,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mocu-xcursor";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "sevmeyer";
    repo = "mocu-xcursor";
    tag = finalAttrs.version;
    hash = "sha256-DVHPUCq3y/f1cVHHKg/qXYr/pGGUcP98RhFuGzNhT/I=";
  };

  nativeBuildInputs = [
    librsvg
    xmlstarlet
    xcursorgen
  ];

  buildPhase = ''
    runHook preBuild
    bash make.sh
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -r dist/* $out/share/icons/
    runHook postInstall
  '';

  meta = {
    description = "Monochrome, minimal cursor theme";
    homepage = "https://github.com/sevmeyer/mocu-xcursor";
    license = lib.licenses.cc0;
    platforms = lib.platforms.linux;
  };
})
