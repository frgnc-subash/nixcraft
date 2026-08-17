{ config, lib, ... }:
let
  cfg = config.userSettings.media;
in
{
  programs.mpv = lib.mkIf cfg.enable {
    enable = true;

    bindings = {
      SPACE = "cycle pause";
      q = "quit";
      f = "cycle fullscreen";
      s = "screenshot";
    };

    config = {
      keep-open = true;
      save-position-on-quit = true;
      autofit-larger = "90%x90%";

      osc = false;
      osd-bar = false;
      border = false;

      vo = "gpu";
      gpu-context = "wayland";

      hwdec = "vaapi";
      vaapi-device = "/dev/dri/renderD128";

      scale = "spline36";
      cscale = "spline36";
      dscale = "mitchell";
      correct-downscaling = true;
      linear-downscaling = true;
      dither-depth = "auto";

      screenshot-format = "png";
      screenshot-directory = "~/Pictures/Screenshots";
    };

    profiles.thumbfast = {
      network = false;
      audio = false;
      sub = false;
      video = false;
      hwdec = false;
      profile = "fast";
    };
  };
}
