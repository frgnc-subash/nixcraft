{ lib, config, pkgs, ... }:
let
  cfg = config.systemSettings.gpu;
in {
  options = {
    systemSettings.gpu = {
      enable = lib.mkEnableOption "Enable NVIDIA Optimus (Intel + NVIDIA hybrid) graphics";
    };
  };
  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
}