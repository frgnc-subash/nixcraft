{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.userSettings.looks;
in
{
  options.userSettings.looks = {
    enable = lib.mkEnableOption "system looks";
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
      inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro
      inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-mono
      inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.ny
    ];

    fonts.fontconfig.enable = true;

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 20;
    };
  };
}
