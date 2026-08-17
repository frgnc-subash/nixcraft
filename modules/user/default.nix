{ config, ... }:

{
  imports = [
    ./hyprland
    ./coding
    ./git
    ./media
    ./games
    ./looks
    ./shell
    ./utils
    ./applications
    ./extra
  ];

  # Keep these paths editable for live development while retaining their
  # source in this flake repository.
  xdg.configFile = {
    btop.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcraft/config/btop";
    cava.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcraft/config/cava";
    eww.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcraft/config/eww";
    fastfetch.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcraft/config/fastfetch";
    hypr.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcraft/config/hypr";
    kitty.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcraft/config/kitty";
    nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcraft/config/nvim";
    quickshell.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcraft/config/quickshell";
    superfile.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcraft/config/superfile";
    themes.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcraft/config/themes";
    tmux.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcraft/config/tmux";
    yazi.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcraft/config/yazi";
    zed.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcraft/config/zed";
  };
}
