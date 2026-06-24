{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.userSettings.editor;
in
{
  options.userSettings.editor = {
    enable = lib.mkEnableOption "editors";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      neovim
      zed-editor
      jdk21

      qt6.qtdeclarative
      nixd
      nil
    ];
  };
}
