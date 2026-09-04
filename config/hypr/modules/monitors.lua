-- ┌┬┐┌─┐┌┐┌┬┌┬┐┌─┐┬─┐┌─┐
-- ││││ │││││ │ │ │├┬┘└─┐
-- ┴ ┴└─┘┘└┘┴ ┴ └─┘┴└─└─┘

hl.monitor({
    output = "eDP-1",
    mode = "1366x768@60.02",
    position = "3393x1056",
    scale = 1.0,
    mirror = "HDMI-A-1",
})
--
-- local scale = 2
--
hl.monitor({
    output = "",
    mode = "highres",
    position = "auto",
    scale = 1.0,
})

hl.config({
    xwayland = { force_zero_scaling = true },
})

hl.env("GDK_SCALE", tostring(1.0))
