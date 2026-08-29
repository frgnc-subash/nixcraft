{
  lib,
  fetchFromGitHub,
  hyprlandPlugins,
  pixman,
  libdrm,
}:
hyprlandPlugins.mkHyprlandPlugin (finalAttrs: {
  pluginName = "hyprglass";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "hyprnux";
    repo = "hyprglass";
    tag = "v${finalAttrs.version}";
    hash = "sha256-x/584kY+XXlU/OWKtZAFo89VtowjLXs1DiP9PC0o0Os=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    mv hyprglass.so $out/lib/libhyprglass.so
    runHook postInstall
  '';

  buildInputs = [
    pixman
    libdrm
  ];

  meta = {
    description = "Liquid Glass inspired plugin for Hyprland (blur, refraction, chromatic aberration)";
    homepage = "https://github.com/hyprnux/hyprglass";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
  };
})
