{ config, lib, pkgs, ... }:
let
  cfg = config.userSettings.games;
in {
  options.userSettings.games = {
    enable = lib.mkEnableOption "gaming tools";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      steam
    ];
  };
}
