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
        cursor_trail = 1;
        cursor_trail_decay = "0.1 0.4";
        cursor_trail_start_threshold = 0;

        allow_remote_control = true;

        scrollbar_handle_opacity = 0;
        scrollbar_track_opacity = 0;
        scrollbar_track_hover_opacity = 0;

        shell = "zsh";
        url_style = "curly";
        remember_window_size = false;

        shell_integration = "no-cursor";

        sync_to_monitor = false;
      };
    };
  };
}
