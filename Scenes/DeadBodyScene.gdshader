shader_type canvas_item;

uniform float radius = 0; // Radius of the visible area
uniform vec4 color : source_color = vec4(1.0); // Color of the texture

void fragment() {
    // Calculate distance from center (0.5, 0.5)
    float dist = distance(UV, vec2(0.5, 0.5));

    // Calculate alpha based on distance
  float alpha = smoothstep(radius, radius + 1.0, dist); // Smooth transition

    // Apply color and alpha
    COLOR = texture(TEXTURE, UV) * color;
    COLOR.a *= alpha;
}
