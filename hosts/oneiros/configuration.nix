{ config, lib, pkgs, ... }:
{
  options.systemSettings = {
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Users to configure via home-manager.";
    };
  };
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/bluetooth
    ../../modules/system/services
    ../../modules/system/gpu
    ../../modules/system/gnome
  ];
  config = {

    systemSettings.users = [ "axosis" ];
    systemSettings.bluetooth.enable = true;
    systemSettings.services.enable = true;
    systemSettings.gpu.enable = true;
    systemSettings.gnome.enable = false;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";
    networking.hostName = "oneiros";
    networking.networkmanager.enable = true;
    time.timeZone = "Asia/Kathmandu";
    i18n.defaultLocale = "en_US.UTF-8";
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    users.users.axosis = {
      isNormalUser = true;
      description = "axosis incon";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.zsh;
      packages = with pkgs; [ ];
    };

    nixpkgs.config.allowUnfree = true;

    services.displayManager.ly.enable = true;

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      # withUWSM = true;
    };

    # programs.enable.uwsm = true;
    programs.zsh.enable = true;
    system.stateVersion = "26.05";
  };
}
