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
    enable = lib.mkEnableOption "Wine, Bottles, and virt-manager";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (bottles.override { removeWarningPopup = true; })
      wineWow64Packages.stable
      winetricks
      virt-manager
    ];
    
    hardware.graphics.enable32Bit = true;

    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    users.users.axosis.extraGroups = [ "libvirtd" ];
  };
}