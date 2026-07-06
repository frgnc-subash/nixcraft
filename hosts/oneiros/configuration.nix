{
  lib,
  pkgs,
  ...
}:
{
  options.systemSettings = {
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Users to configure via home-manager.";
    };
  };
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/bluetooth
    ../../modules/system/services
    ../../modules/system/gpu
    ../../modules/system/gnome
    ../../modules/system/storage
    ../../modules/system/virtualization
    ../../modules/system/sddm
  ];
  config = {
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_7_1;

    systemSettings.users = [ "axosis" ];
    systemSettings.bluetooth.enable = true;
    systemSettings.services.enable = true;
    systemSettings.gpu.enable = true;
    systemSettings.gnome.enable = false;
    systemSettings.storage.enable = true;
    systemSettings.virtualization.enable = true;
    systemSettings.sddm = {
      enable = true;
      theme = "rei";
      avatar = ../../assets/pfp.png; 
    };

    services.gnome.gnome-keyring.enable = true;
    services.displayManager.ly.enable = false;
    security.pam.services.ly.enableGnomeKeyring = true;
    security.polkit.enable = true;

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
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      shell = pkgs.zsh;
    };

    nixpkgs.config = {
      allowUnfree = true;

      permittedInsecurePackages = [
        "pnpm-10.29.2"
      ];
    };

    services.flatpak.enable = true;

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nix.settings.auto-optimise-store = true;

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    environment.systemPackages = [ pkgs.polkit_gnome ];
    # programs.enable.uwsm = true;
    programs.zsh.enable = true;
    system.stateVersion = "26.05";
    programs.nix-ld.enable = true;
  };
}
