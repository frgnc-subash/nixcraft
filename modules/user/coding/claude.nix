{
  config,
  lib,
  ...
}:
let
  cfg = config.userSettings.claude;

  mkClaudeFn = name: model: ''
    claude-${name}() {
      (
        set -a
        source ${cfg.envFile}
        set +a
        env -u ANTHROPIC_API_KEY \
          ANTHROPIC_BASE_URL="https://openrouter.ai/api" \
          ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY" \
          OPENROUTER_API_KEY="$OPENROUTER_API_KEY" \
          ANTHROPIC_MODEL="${model}" \
          claude "$@"
      )
    }
  '';

  claudeOrScript = lib.concatStringsSep "\n" (
    lib.mapAttrsToList mkClaudeFn cfg.models
  );
in
{
  options.userSettings.claude = {
    enable = lib.mkEnableOption "claude openrouter routing";

    envFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/nixcraft/.env";
      description = "Path to a .env file containing OPENROUTER_API_KEY. Read at runtime, never embedded in the Nix store.";
    };

    models = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        or = "nvidia/nemotron-3-ultra-550b-a55b:free";
        kimi = "moonshotai/kimi-k2-thinking";
        qwen = "qwen/qwen3-coder:free";
      };
      description = ''
        Attrset of name -> OpenRouter model slug. Generates a `claude-<name>`
        shell function for each entry, e.g. `claude-or`, `claude-kimi`, `claude-qwen`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.bash.initExtra = lib.mkIf config.programs.bash.enable claudeOrScript;
    programs.zsh.initContent = lib.mkIf config.programs.zsh.enable claudeOrScript;
  };
}