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
    home.sessionPath = [ "${config.home.homeDirectory}/.config/emacs/bin" ];

    home.packages = with pkgs; [

      # editors
      vim
      neovim
      zed-editor
      claude-code
      emacs
      antigravity-ide
      jetbrains.idea

      # languages & runtimes
      jdk21
      nodejs_24
      bun
      python3
      maven

      eww
      quickshell

      rustup
      clang
      clang-tools
      gcc
      cmake
      nixd
      nil
      pkgs.go
      pkgs.gopls
      pkgs.gotools
      uv
      qt6.qtdeclarative
    ];
  };
}
