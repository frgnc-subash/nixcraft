{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.shell;
in {
  imports = [ ./settings.nix ./starship.nix ];

  options.userSettings.shell = {
    enable = lib.mkEnableOption "shell configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable                    = true;
      enableCompletion          = true;
      autosuggestion.enable     = true;
      syntaxHighlighting.enable = true;
    };

    programs.fzf = {
      enable               = true;
      enableZshIntegration = true;
    };

    programs.zoxide = {
      enable               = true;
      enableZshIntegration = true;
      options              = [ "--cmd" "cd" ];
    };

    programs.starship = {
      enable               = true;
      enableZshIntegration = true;
    };

    programs.eza.enable = true;

    home.packages = with pkgs; [
      bat
      tmux
      tree
    ];
  };
}
