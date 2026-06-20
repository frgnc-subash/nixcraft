{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.userSettings.applications;
in {
  options = {
    userSettings.applications = {
      enable = lib.mkEnableOption "Enable applications apps";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      vesktop
      proton-authenticator
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      libreoffice-still
      errands
      zathura
      zathuraPkgs.zathura_pdf_poppler
    ];
  };
}