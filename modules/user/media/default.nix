{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.media;
in {
  options = {
    userSettings.media = {
      enable = lib.mkEnableOption "Enable media playback apps";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      mpv
      ffmpeg
      swappy
      pulseaudio
      loupe
    ];

  };
}
