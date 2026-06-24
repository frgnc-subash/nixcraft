{ config, lib, ... }:

let
  cfg = config.userSettings.terminal;
in {
  options.userSettings.terminal = {
    enable = lib.mkEnableOption "terminal emulator";
  };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;

      font = {
        name = "JetBrainsMono Nerd Font";
        size = 12;
      };

      settings = {
        window_padding_width = 15;

        background_opacity = 0.95;

        cursor_shape = "block";
        cursor_blink_interval = 0;

        allow_remote_control = true;

        scrollbar_handle_opacity = 0;
        scrollbar_track_opacity = 0;
        scrollbar_track_hover_opacity = 0;

        shell = "zsh";
        url_style = "curly";
        remember_window_size = false;

        sync_to_monitor = false;
      };
    };
  };
}