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
      vim
      neovim
      zed-editor
      vscode
      jdk21
      qt6.qtdeclarative
      nixd
      nil
    ];
  };
}
