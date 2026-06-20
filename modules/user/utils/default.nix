{ config, lib, pkgs, ... }:
let
  cfg = config.userSettings.utils;
in {
  options.userSettings.utils = {
    enable = lib.mkEnableOption "utils utilities";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      neovim  
      vim
      tmux
      
      wget
      curl

      rustc
      cargo
      gcc

      eww
      quickshell
    ];
  };
}