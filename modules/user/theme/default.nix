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
      noto-fonts-color-emoji
      material-symbols
      inter
      mononoki
      monaspace
      corefonts
    ];

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 20;
    };
  };
}
