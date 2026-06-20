{ config, lib, pkgs, ... }:
let
  cfg = config.userSettings.hyprland;
in {
  options.userSettings.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      waybar
      swaynotificationcenter
      rofi
      hypridle
      hyprlock
      hyprsunset
      swayosd
      cliphist
      wl-clipboard
      grimblast
      playerctl
      polkit_gnome
      awww
      wiremix
    ];
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      configPackages = [ pkgs.hyprland ];
    };
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit.Description = "Polkit GNOME Authentication Agent";
      Unit.After = [ "graphical-session.target" ];
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
      };
    };
    home.sessionVariables = {
      XDG_CURRENT_DESKTOP  = "Hyprland";
      XDG_SESSION_TYPE     = "wayland";
      XDG_SESSION_DESKTOP  = "Hyprland";
      QT_QPA_PLATFORM      = "wayland";
      QT_QPA_PLATFORMTHEME = "qt6ct";
      XCURSOR_SIZE         = "20";
      HYPRCURSOR_SIZE      = "20";
      XCURSOR_THEME        = "Mocu-Black-Right";
      TERMINAL             = "kitty";
    };
  };
}