#!/usr/bin/env python3
"""Generate quickshell.js for every theme, using theme values as-is."""

import os
import re

THEMES_DIR = os.path.expanduser("~/.config/themes")

# Semantic UI accents keep controls expressive without making surfaces noisy.
# Each set is selected to belong to its theme, rather than applying generic
# blue/orange/green hues that clash with the surrounding palette.
SEMANTIC_ACCENTS = {
    "gruvbox": {"info": "#83a598", "warning": "#fe8019", "success": "#b8bb26"},
    "mocha": {"info": "#89b4fa", "warning": "#fab387", "success": "#a6e3a1"},
    "monochrome": {"info": "#b0b0b0", "warning": "#d0d0d0", "success": "#909090"},
    "moonfly": {"info": "#78a8ff", "warning": "#e3c78a", "success": "#8cc85f"},
    "ryo": {"info": "#8bd5ff", "warning": "#f0b080", "success": "#8ff0c7"},
    "tokyonight": {"info": "#7dcfff", "warning": "#ff9e64", "success": "#9ece6a"},
}


def rgb(color):
    """Return RGB channels from a CSS hex or rgba() color.

    The palette itself keeps rgba() strings intact for QML so translucent themes
    such as Ryo retain their glassy surfaces; alpha is deliberately ignored for
    the contrast and blend calculations below.
    """
    if color.startswith("#"):
        return tuple(int(color[i : i + 2], 16) for i in (1, 3, 5))
    match = re.match(r"rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)", color)
    if match:
        return tuple(int(match.group(i)) for i in range(1, 4))
    raise ValueError(f"Unsupported color: {color}")


def blend(c1, c2, t):
    r1, g1, b1 = rgb(c1)
    r2, g2, b2 = rgb(c2)
    return (
        f"#{max(0, min(255, int(round(r1 + (r2 - r1) * t)))):02x}"
        f"{max(0, min(255, int(round(g1 + (g2 - g1) * t)))):02x}"
        f"{max(0, min(255, int(round(b1 + (b2 - b1) * t)))):02x}"
    )


def parse(value):
    value = value.strip().rstrip(";")
    if value.startswith("#"):
        return value
    m = re.match(r"rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([0-9.]+)\s*\)", value)
    if m:
        return f"rgba({int(m.group(1))}, {int(m.group(2))}, {int(m.group(3))}, {m.group(4)})"
    return None


def luminance(h):
    r, g, b = rgb(h)
    return 0.299 * r + 0.587 * g + 0.114 * b


def cr(a, b):
    la = luminance(a) + 0.05
    lb = luminance(b) + 0.05
    return max(la, lb) / min(la, lb)


def ensure_contrast(text, bg, minimum):
    """Brighten text toward white until contrast >= minimum against bg."""
    if cr(text, bg) >= minimum:
        return text
    lo, hi = 0.0, 1.0
    for _ in range(24):
        t = (lo + hi) / 2
        c = blend(text, "#ffffff", t)
        if cr(c, bg) >= minimum:
            hi = t
        else:
            lo = t
    return blend(text, "#ffffff", hi)


for name in sorted(os.listdir(THEMES_DIR)):
    path = os.path.join(THEMES_DIR, name)
    css = os.path.join(path, "waybar.css")
    if not os.path.isfile(css):
        continue
    c = {}
    with open(css) as f:
        for line in f:
            m = re.match(r"@define-color\s+(\S+)\s+(.+);", line)
            if m:
                val = parse(m.group(2))
                if val:
                    c[m.group(1)] = val

    g = c.get
    semantic = SEMANTIC_ACCENTS.get(name, {})
    bg = g("surface_container_lowest", g("background", "#000"))

    # Surfaces — darkened if too light for readable text
    rawSCL = g("surface_container_low", bg)
    rawSC = g("surface_container", rawSCL)
    rawSCH = g("surface_container_high", rawSC)
    rawSCH2 = g("surface_container_highest", rawSCH)

    # Ensure each surface level is dark enough that white text is readable.
    # Target: white (#fff, lum 255) should have CR >= 4.5 against the surface.
    def darken_surface(surf, minimum, darker_bg):
        """Blend surface toward darker_bg until white text achieves minimum CR."""
        if cr("#ffffff", surf) >= minimum:
            return surf
        lo, hi = 0.0, 1.0
        for _ in range(24):
            t = (lo + hi) / 2
            c = blend(surf, darker_bg, t)
            if cr("#ffffff", c) >= minimum:
                hi = t
            else:
                lo = t
        return blend(surf, darker_bg, hi)

    surfaceContainerLow = darken_surface(rawSCL, 4.5, bg)
    surfaceContainer = darken_surface(rawSC, 4.5, surfaceContainerLow)
    surfaceContainerHigh = darken_surface(rawSCH, 4.0, surfaceContainer)
    surfaceContainerHighest = darken_surface(rawSCH2, 3.5, surfaceContainerHigh)

    surface = bg
    surfaceTint = g("on_surface", "#fff")

    # Outline / border
    rawOV = g("outline_variant", "#555")
    outlineVariant = rawOV
    border = rawOV
    # Workspace dots need to remain visible on transparent/AMOLED surfaces.
    # Blend to an opaque shade: passing an rgba() outline through directly lets
    # it disappear when composited over Ryo's black background.
    wsInactive = blend(bg, g("outline", rawOV), 0.70)

    # Accent
    accent = g("primary", "#fff")
    onAccent = g("on_primary", "#000")
    info = semantic.get("info", g("secondary", accent))
    warning = semantic.get("warning", g("tertiary", accent))
    success = semantic.get("success", g("tertiary", accent))
    error = g("error", "#ff6b6b")
    accentLight = blend(bg, accent, 0.10)
    primaryContainer = g("primary_container", surfaceContainer)
    onPrimaryContainer = g("on_primary_container", accent)

    # Secondary
    secondaryAccent = g("secondary", accent)
    secondaryContainer = g("secondary_container", surfaceContainer)
    onSecondaryContainer = g("on_secondary_container", g("on_surface", "#fff"))
    secondaryContainerHover = blend(surfaceContainerHighest, accent, 0.08)

    # Text — exact from CSS
    textPrimary = g("on_surface", "#fff")
    textSecondary = g("on_surface_variant", "#ccc")
    textMuted = g("outline", "#888")
    textDisabled = rawOV

    # Ensure readable contrast for 10-12px UI text against surfaceContainer
    textPrimary = ensure_contrast(textPrimary, surfaceContainer, 4.5)
    textTitle = textPrimary
    textSecondary = ensure_contrast(textSecondary, surfaceContainer, 4.5)
    # Flatten muted text to an opaque blend. Transparent outline colors look
    # far darker once composited over Ryo's AMOLED background.
    textMuted = ensure_contrast(blend(bg, textMuted, 0.75), surfaceContainer, 3.5)
    textDisabled = ensure_contrast(textDisabled, surfaceContainer, 2.5)

    lines = [
        f'const bg = "{bg}"',
        f'const surface = "{surface}"',
        f'const surfaceContainerLow = "{surfaceContainerLow}"',
        f'const surfaceContainer = "{surfaceContainer}"',
        f'const surfaceContainerHigh = "{surfaceContainerHigh}"',
        f'const surfaceContainerHighest = "{surfaceContainerHighest}"',
        f'const surfaceTint = "{surfaceTint}"',
        f'const outlineVariant = "{outlineVariant}"',
        f'const border = "{border}"',
        f'const accent = "{accent}"',
        f'const onAccent = "{onAccent}"',
        f'const info = "{info}"',
        f'const warning = "{warning}"',
        f'const success = "{success}"',
        f'const error = "{error}"',
        f'const accentLight = "{accentLight}"',
        f'const primaryContainer = "{primaryContainer}"',
        f'const onPrimaryContainer = "{onPrimaryContainer}"',
        f'const secondaryContainer = "{secondaryContainer}"',
        f'const secondaryContainerHover = "{secondaryContainerHover}"',
        f'const onSecondaryContainer = "{onSecondaryContainer}"',
        f'const wsInactive = "{wsInactive}"',
        f'const textPrimary = "{textPrimary}"',
        f'const textTitle = "{textTitle}"',
        f'const textSecondary = "{textSecondary}"',
        f'const textMuted = "{textMuted}"',
        f'const textDisabled = "{textDisabled}"',
    ]

    with open(os.path.join(path, "quickshell.js"), "w") as f:
        f.write("\n".join(lines) + "\n")

    print(f"✓ {name}")
