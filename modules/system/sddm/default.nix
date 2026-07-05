{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.systemSettings.sddm;
in
{
  imports = [ inputs.silentSDDM.nixosModules.default ];

  options.systemSettings.sddm = {
    enable = lib.mkEnableOption "SilentSDDM display manager";
    theme = lib.mkOption {
      type = lib.types.str;
      default = "rei";
      description = "SilentSDDM theme to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.silentSDDM = {
      enable = true;
      theme = cfg.theme;
    };
  };
}
