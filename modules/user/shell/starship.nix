{ config, lib, ... }:
let
  cfg = config.userSettings.shell;
in
{
  config = lib.mkIf cfg.enable {
    programs.starship.settings = {
      add_newline = false;
      format = "[󰫣](fg:purple) $directory $git_branch $git_status  [](fg:yellow) $fill $lua $nodejs $rust $python $docker_context $jobs $cmd_duration $line_break $character";
      fill.symbol = " ";
      character = {
        success_symbol = "[󰁕](bold blue)";
        error_symbol = "[󰁕](bold red)";
      };
      directory = {
        style = "fg:magenta";
        format = "$path";
        truncation_length = 1;
        truncation_symbol = "";
        substitutions = {
          "Desktop" = "󰍹 ";
          "Documents" = "󰈙 ";
          "Downloads" = "󰇚 ";
          "Music" = "󰝚 ";
          "Pictures" = "󰋹 ";
          "Projects" = "󱓞 ";
          "nixcraft" = "󱄅 ";
        };
      };
      username = {
        show_always = true;
        style_user = "bold fg:cyan";
        format = "[$user]($style)";
      };
      git_branch = {
        symbol = "󰘬";
        style = "fg:cyan";
        format = "'[ $branch $symbol ]($style)'";
      };
      git_status = {
        conflicted = " 󰀦 ";
        ahead = " 󱞨 ";
        behind = " 󱞦 ";
        diverged = " 󰦻 ";
        untracked = " 󰋖 ";
        stashed = " 󰀼 ";
        modified = " 󰏫 ";
        staged = "'[++(\\$count)](green)'";
        renamed = " 󰑕 ";
        deleted = " 󰗩 ";
      };
      git_commit = {
        commit_hash_length = 4;
        tag_symbol = " 󰓹 ";
      };
      time = {
        disabled = true;
        time_format = "%R";
        style = "fg:blue";
        format = "$time";
      };
      cmd_duration = {
        disabled = false;
        min_time = 500;
        format = "[󱤤 $duration]($style)";
        style = "fg:yellow";
      };
      jobs.symbol = "󱍸";
      nodejs.symbol = "󰎙";
      python.symbol = "󰌠";
      rust.symbol = "󱘗";
      lua.symbol = "󰢱";
    };
  };
}
