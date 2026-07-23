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
      cowsay
      fastfetch
      htop
      pokeget-rs
      pipes-rs
      # momoi
      nitch
      peaclock
      cbonsai
    ];
  };
}
