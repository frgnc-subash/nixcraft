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
    user = lib.mkOption {
      type = lib.types.str;
      default = "axosis";
      description = "User to set the SDDM avatar for.";
    };
    avatar = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a PNG/JPG to use as the SDDM login avatar for `user`. Set to null to skip.";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.silentSDDM = {
      enable = true;
      theme = cfg.theme;
    };

    systemd.tmpfiles.rules = lib.mkIf (cfg.avatar != null) [
      "f+ /var/lib/AccountsService/users/${cfg.user} 0600 root root - [User]\\nIcon=/var/lib/AccountsService/icons/${cfg.user}\\n"
      "L+ /var/lib/AccountsService/icons/${cfg.user} - - - - ${cfg.avatar}"
    ];
  };
}
