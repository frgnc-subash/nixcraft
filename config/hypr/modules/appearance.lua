-- ┌─┐┌─┐┌─┐┌─┐┌─┐┬─┐┌─┐┌┐┌┌─┐┌─┐
-- ├─┤├─┘├─┘├┤ ├─┤├┬┘├─┤││││  ├┤
-- ┴ ┴┴  ┴  └─┘┴ ┴┴└─┴ ┴┘└┘└─┘└─┘

-- dofile(os.getenv("HOME") .. "/.config/matugen/generated/hypr-colors.lua")
local theme = dofile(os.getenv("HOME") .. "/.config/hypr/theme.lua")

-- Selected via the Quickshell shader picker (quickshell/modules/shader);
-- falls back to the default corner shader if the state file is missing.
local screen_shader = os.getenv("HOME") .. "/.config/hypr/shaders/rounded_corners.glsl"
do
    local ok, state_shader = pcall(dofile, os.getenv("HOME") .. "/.config/hypr/shader.lua")
    if ok and type(state_shader) == "string" then
        screen_shader = state_shader
    end
end

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 4,
        border_size = 0,
        ["col.active_border"] = theme.outline,
        ["col.inactive_border"] = theme.outline_variant,
        resize_on_border = true,
        allow_tearing = false,
    },

    decoration = {
        rounding = 6,
        rounding_power = 8,
        active_opacity = 0.90,
        inactive_opacity = 0.95,
        screen_shader = screen_shader,

        shadow = {
            enabled = false,
            range = 2,
            render_power = 2,
            color = theme.primary,
        },

        blur = {
            enabled = true,
            size = 4,
            passes = 2,
            new_optimizations = true,
            ignore_opacity = true,
            noise = 0.05,
            brightness = 1,
            contrast = 1,
        },
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 1,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        -- vfr = false,
        enable_swallow = true,
    },

    ecosystem = {
        no_update_news = true,
    }
})
