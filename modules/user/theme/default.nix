{ config, lib, pkgs, ... }:
let
  cfg = config.userSettings.theme;
in {
  options.userSettings.theme = {
    enable = lib.mkEnableOption "adw-gtk3 theme";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      adw-gtk3
      papirus-icon-theme
      bibata-cursors
      nerd-fonts.jetbrains-mono
      nerd-fonts.departure-mono
      nerd-fonts.geist-mono
      inter
      noto-fonts-color-emoji
    ];
  };
}