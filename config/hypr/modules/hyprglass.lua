-- ┬ ┬┬ ┬┌─┐┬─┐┌─┐┬  ┌─┐┌─┐┌─┐
-- ├─┤└┬┘├─┘├┬┘│ ┬│  ├─┤└─┐└─┐
-- ┴ ┴ ┴ ┴  ┴└─└─┘┴─┘┴ ┴└─┘└─┘

-- Built by ./modules/user/hyprland/hyprglass.nix and linked into the home-manager
-- profile, so this path is stable across rebuilds even though the store path
-- backing it isn't. useUserPackages = true means the real profile lives under
-- /etc/profiles/per-user, not ~/.nix-profile.
hl.plugin.load("/etc/profiles/per-user/" .. os.getenv("USER") .. "/lib/libhyprglass.so")

if hl.plugin.hyprglass then
    local hg = hl.plugin.hyprglass

    hg.config({
        -- Preview mode: only windows tagged hyprglass_enabled get the effect.
        enabled = false,
        default_theme = "light",
        default_preset = "clear",

        -- Layer surfaces (bars, quickshell popups, etc.) are a separate opt-in
        -- from window tags; leave them off so only kitty gets the effect.
        layers = { enabled = 0 },
    })

    hg.preset("clear", {
        glass_opacity = 0.8,
        blur_strength = 1.5,
        dark = { brightness = 0.82 },
        light = { brightness = 1.12 },
    })

    hl.window_rule({ match = { class = "kitty" }, tag = "+hyprglass_enabled" })
    hl.window_rule({ match = { class = "kitty" }, tag = "+hyprglass_preset_glass" })
    hl.window_rule({
        name = "kitty-glass-opacity",
        match = { class = "kitty" },
        opacity = "0.85 override",
    })
end
