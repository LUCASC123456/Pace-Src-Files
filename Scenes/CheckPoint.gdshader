shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;

uniform float line_width = 0.02;
uniform float line_spacing = 0.2;
uniform vec4 line_color : source_color = vec4(1.0, 0.5, 0.0, 0.75);
uniform vec4 base_color : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform float rotation_speed = 1.0;
uniform float time_offset = 0.0;

// How "flat" the top needs to be before it counts as top
uniform float top_normal_threshold = 0.9;

void fragment() {
    // If the surface normal points mostly upward (y near 1), make invisible
    if (NORMAL.y > top_normal_threshold) {
        discard; // Completely remove this pixel
    }

    vec2 uv = UV;
    uv.x += TIME * rotation_speed + time_offset;

    float angle = 0.2;
    float cos_a = cos(angle);
    float sin_a = sin(angle);
    vec2 rotated_uv;
    rotated_uv.x = uv.x * cos_a - uv.y * sin_a;
    rotated_uv.y = uv.x * sin_a + uv.y * cos_a;

    float line = step(line_width, abs(fract(rotated_uv.x / line_spacing) - 0.5));

    vec4 color = mix(base_color, line_color, line);
    ALBEDO = color.rgb;
    ALPHA = color.a;
}