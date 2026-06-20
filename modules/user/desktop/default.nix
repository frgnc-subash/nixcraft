{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.desktop;
in {
  imports = [
    ./hyprland
  ];

  options.userSettings.desktop = {
    enable = lib.mkEnableOption "desktop applications";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nautilus
      nwg-look
    ];
  };
}
