{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.systemSettings.virtualization;
in
{
  options.systemSettings.virtualization = {
    enable = lib.mkEnableOption "Wine and Bottles";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (bottles.override { removeWarningPopup = true; })
      wineWow64Packages.stable
      winetricks
    ];
    hardware.graphics.enable32Bit = true;
  };
}
