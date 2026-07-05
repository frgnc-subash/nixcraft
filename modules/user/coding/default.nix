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
      (pkgs.dotnetCorePackages.combinePackages [
        pkgs.dotnetCorePackages.sdk_9_0
      ])
      pkgs.csharp-ls
      qt6.qtdeclarative
      nixd
      nil
    ];
  };
}
