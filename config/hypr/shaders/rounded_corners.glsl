#version 300 es
// Rounded Screen Corners
// Description: Paints small black quarter-circle masks over the four
// physical screen corners to fake a rounded-corner display.

precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

// --- CONFIGURATION ---
// Corner radius in pixels. Matches decoration.rounding in appearance.lua.
const float RADIUS = 12.0;
// Screen resolution in pixels — must match your monitor's mode (see
// modules/monitors.lua) or the curve will look slightly elliptical.
const vec2 RESOLUTION = vec2(1366.0, 768.0);
// Antialiasing softness in pixels.
const float AA = 1.0;

void main() {
    vec4 color = texture(tex, v_texcoord);
    vec2 pixel = v_texcoord * RESOLUTION;

    bool nearLeft = pixel.x < RADIUS;
    bool nearRight = pixel.x > RESOLUTION.x - RADIUS;
    bool nearTop = pixel.y < RADIUS;
    bool nearBottom = pixel.y > RESOLUTION.y - RADIUS;

    if ((nearLeft || nearRight) && (nearTop || nearBottom)) {
        vec2 corner = vec2(nearLeft ? RADIUS : RESOLUTION.x - RADIUS, nearTop ? RADIUS : RESOLUTION.y - RADIUS);
        float dist = distance(pixel, corner);
        float mask = smoothstep(RADIUS - AA, RADIUS + AA, dist);
        color.rgb = mix(color.rgb, vec3(0.0), mask);
    }

    fragColor = color;
}
