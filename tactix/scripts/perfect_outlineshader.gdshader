shader_type spatial;
render_mode cull_front, unshaded;

// Outline color (can be semi-transparent)
uniform vec4 outline_color : source_color;
  
// Outline pixel size multiplier
uniform float outline_width = 1.0;

void vertex() {
    // Get transformed vertex in clip space
    vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));

    // Compute normal in clip space
    vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * NORMAL);

    // Convert normal to 2D and normalize
    vec2 normal2d = normalize(clip_normal.xy);

    // Adjust position relative to the viewport for pixel perfect offset
    // Multiply by clip_position.w so outline thickness stays consistent
    vec2 offset = normal2d * outline_width * clip_position.w / VIEWPORT_SIZE.xy;

    // Apply offset
    clip_position.xy += offset;

    // Set the final vertex position
    POSITION = clip_position;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
}
