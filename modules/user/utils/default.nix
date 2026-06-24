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
      bat
      tree
      tmux
      ripgrep
      dust

      wget
      curl

      rustc
      cargo
      gcc
      python3
      vips
      util-linux
      libsecret  # provides secret-tool
      python3.withPackages (ps: [ ps.pygobject3 ])

      eww
      quickshell
    ];
  };
}
