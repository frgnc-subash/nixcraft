{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.git;
in {
  options.userSettings.git = {
    enable = lib.mkEnableOption "git configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "*" = {
          AddKeysToAgent = "yes";
        };
        "github.com" = {
          Hostname      = "github.com";
          User          = "git";
          IdentityFile  = "~/.ssh/github";
          IdentitiesOnly = true;
        };
      };
    };

    services.ssh-agent.enable = true;
    programs.git = {
      enable = true;

      settings = {
        user.name  = "axosis";
        user.email = "axosis.social357@gmail.com";
        init.defaultBranch = "main";

        pull.rebase = true;
        push.autoSetupRemote = true;

        fetch.prune = true;

        core.editor = "zeditor";

        color.ui = "auto";

        alias = {
          st = "status";
          lg = "log --oneline --graph --decorate --all";
          co = "checkout";
          br = "branch";
          cm = "commit";
        };
      };
    };
  };
}
