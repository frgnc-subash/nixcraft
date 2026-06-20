{ pkgs, config, lib, ... }:
let
  cfg = config.systemSettings.gnome;
in
{
  options = {
    systemSettings.gnome = {
      enable = lib.mkEnableOption "Enable gnome";
    };
  };
  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    environment.gnome.excludePackages = with pkgs; [
      orca
      evince
      file-roller
      geary
      seahorse
      sushi
      sysprof
      baobab
      epiphany
      gnome-text-editor
      gnome-characters
      gnome-console
      gnome-contacts
      gnome-font-viewer
      gnome-logs
      gnome-maps
      gnome-music
      gnome-system-monitor
      gnome-weather
      gnome-connections
      simple-scan
      snapshot
      totem
      yelp
      gnome-software
    ];
  };
}