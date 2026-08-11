{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.userSettings.coding;
in
{
  options.userSettings.coding = {
    enable = lib.mkEnableOption "coding";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [

      # editors
      vim
      neovim
      zed-editor
      antigravity-ide

      # languages & runtimes
      jdk21
      nodejs_24
      bun
      python3
      mariadb
 
      eww
      quickshell


      # rust
      rustup

      # build tools / compilers
      gcc
      cmake

      # nix tooling (LSP + linter)
      nixd
      nil

      # go lang
      pkgs.go
      pkgs.gopls
      pkgs.gotools

      # python package manager
      uv

      # Qt / GUI dev
      qt6.qtdeclarative
    ];
  };
}
