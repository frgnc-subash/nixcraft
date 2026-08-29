-- ┬ ┬┬ ┬┌─┐┬─┐┌─┐┬  ┌─┐┌─┐┌─┐
-- ├─┤└┬┘├─┘├┬┘│ ┬│  ├─┤└─┐└─┐
-- ┴ ┴ ┴ ┴  ┴└─└─┘┴─┘┴ ┴└─┘└─┘

hl.plugin.load("/etc/profiles/per-user/" .. os.getenv("USER") .. "/lib/libhyprglass.so")

if hl.plugin.hyprglass then
    local hg = hl.plugin.hyprglass

    hg.config({
        enabled = false,
        default_theme = "light",
        default_preset = "apple",
        layers = { enabled = 0 },
    })

    hg.preset("apple", {
        blur_strength        = 2.2,
        blur_iterations      = 3,
        refraction_strength  = 0.55,
        chromatic_aberration = 0.3,
        fresnel_strength     = 0.5,
        specular_strength    = 0.75,
        edge_thickness       = 0.05,
        lens_distortion      = 0.3,
        dark                 = { brightness = 0.82, contrast = 0.90, saturation = 0.80, vibrancy = 0.15, adaptive_dim = 0.4 },
        light                = { brightness = 1.12, contrast = 0.92, saturation = 0.85, vibrancy = 0.12, adaptive_boost = 0.4 },
    })

    hg.preset("clear", {
        glass_opacity = 0.80,
        edge_thickness = 0.10,
        blur_strength = 1.0,
        dark = { brightness = 0.82 },
        light = { brightness = 1.12 },
    })

    hg.preset("contrasted", {
        inherits = "high_contrast",
        contrast = 1.2,
        adaptive_dim = 1.2,
        dark = { brightness = 0.82 },
        light = { brightness = 1.12 },

    })


    hl.window_rule({ match = { class = "kitty" }, tag = "+hyprglass_enabled" })
    hl.window_rule({ match = { class = "kitty" }, tag = "+hyprglass_preset_glass" })
    hl.window_rule({
        name = "kitty-glass-opacity",
        match = { class = "kitty" },
        opacity = "0.80 override",
    })
end
