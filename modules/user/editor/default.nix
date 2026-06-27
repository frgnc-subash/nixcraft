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
      vim
      neovim
      zed-editor
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
