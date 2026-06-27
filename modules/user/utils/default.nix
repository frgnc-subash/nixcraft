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

      rustc
      cargo
      gcc
      python3
      vips
      util-linux
      libsecret # provides secret-tool
      # python3.withPackages (ps: [ ps.pygobject3 ])
      gnome-disk-utility

      eww
      quickshell
    ];
  };
}
