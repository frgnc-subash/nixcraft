#version 300 es

precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

const float RADIUS = 8.0;

const vec2 RESOLUTION = vec2(1366.0, 768.0);
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
