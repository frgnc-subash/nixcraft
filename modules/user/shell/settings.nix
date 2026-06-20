{ config, lib, ... }:

let
  cfg = config.userSettings.shell;
in {
  config = lib.mkIf cfg.enable {

    # ── Exports ───────────────────────────────────────────────────────────────
    home.sessionVariables = {
      EDITOR   = "nvim";
      VISUAL   = "nvim";
      TERMINAL = "kitty";
    };

    home.sessionPath = [
      "$HOME/.config/hypr/scripts"
    ];

    # ── Aliases ───────────────────────────────────────────────────────────────
    programs.zsh.shellAliases = {
      # System
      ping   = "ping -c 5";
      rm     = "rm -i";
      ".."   = "cd ..";
      vim    = "nvim";
      cat    = "bat --paging=never";

      # eza
      ls     = "eza --icons";
      ll     = "eza -l --icons";
      la     = "eza -lah --color=always --group-directories-first";
      lah    = "eza -lah --icons --group-directories-first";
      "l."   = "eza -la --icons | grep \"^\\.\"";
      lt     = "eza --tree -L 2 --icons";
      ld     = "eza -lD --icons";

      # Tmux
      tl     = "tmux list-sessions";
      tk     = "tmux kill-server";

      # Dotfiles bare repo
      # dot    = "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME --no-pager";
    };

    # ── History ───────────────────────────────────────────────────────────────
    programs.zsh.history = {
      size        = 5000;
      save        = 5000;
      path        = "$HOME/.zsh_history";
      ignoreDups  = true;
      ignoreSpace = true;
      share       = true;
    };

    # ── Settings, keybinds, completions, tmux function ────────────────────────
    programs.zsh.initContent = ''
      # --- Keybindings ---
      bindkey -e
      bindkey '^p' history-search-backward
      bindkey '^n' history-search-forward

      # --- History opts ---
      setopt appendhistory
      setopt sharehistory
      setopt hist_ignore_space
      setopt hist_ignore_all_dups
      setopt hist_save_no_dups
      setopt hist_ignore_dups
      setopt hist_find_no_dups

      # --- Completion styling ---
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

      # --- Tmux session picker ---
      new_tmux() {
        session_dir=$(zoxide query --list | fzf --preview 'ls -la {}') || return
        session_name=$(basename "$session_dir")
        if tmux has-session -t "$session_name" 2>/dev/null; then
          if [ -n "$TMUX" ]; then
            tmux switch-client -t "$session_name"
          else
            tmux attach-session -t "$session_name"
          fi
        else
          if [ -n "$TMUX" ]; then
            tmux new-session -d -c "$session_dir" -s "$session_name"
            tmux switch-client -t "$session_name"
          else
            tmux new-session -c "$session_dir" -s "$session_name"
          fi
        fi
      }
      alias tm=new_tmux
    '';
  };
}
