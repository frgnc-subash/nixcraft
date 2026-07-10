{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.userSettings.utils;
in
{
  options.userSettings.utils = {
    enable = lib.mkEnableOption "utils utilities";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wget
      curl

      vips
      util-linux
      libsecret # provides secret-tool
      eww
      quickshell
    ];
  };
}
