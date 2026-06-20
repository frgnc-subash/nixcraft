{ lib, config, ... }:
let
  cfg = config.systemSettings.dataSSD;
in {
  options = {
    systemSettings.dataSSD = {
      enable = lib.mkEnableOption "Mount the DataSSD drive";
    };
  };
  config = lib.mkIf cfg.enable {
    fileSystems."/mnt/DataSSD" = {
      device = "/dev/disk/by-uuid/3f9e646d-90e9-45b7-875b-f715d705689d";
      fsType = "ext4";
      options = [ "defaults" ];
    };
  };
}