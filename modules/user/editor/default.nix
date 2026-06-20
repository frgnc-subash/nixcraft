{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.editor;
in {
  options.userSettings.editor = {
    enable = lib.mkEnableOption "editors";
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
    };

    home.packages = with pkgs; [
      neovim
      zed-editor
    ];
  };
}
