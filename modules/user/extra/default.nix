# modules/user/extra/default.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.userSettings.extra;
in {
  options.userSettings.extra = {
    enable = lib.mkEnableOption "extra utilities";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      asciiquarium
      btop
      cava
      cmatrix
      fortune
      lolcat
      cowsay
      fastfetch
      htop
      pokeget-rs
      pipes-rs
      nitch
      peaclock
      cbonsai
    ];
  };
}
