{
  lib,
  fetchFromGitHub,
  hyprlandPlugins,
  pixman,
  libdrm,
}:

hyprlandPlugins.mkHyprlandPlugin hyprlandPlugins.hyprland {
  pluginName = "hyprglass";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "hyprnux";
    repo = "hyprglass";
    rev = "v0.7.2";
    hash = lib.fakeHash; # placeholder — see step 2
  };

  buildInputs = [ pixman libdrm ];

  meta = with lib; {
    description = "Liquid Glass inspired plugin for Hyprland (blur, refraction, chromatic aberration)";
    homepage = "https://github.com/hyprnux/hyprglass";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}