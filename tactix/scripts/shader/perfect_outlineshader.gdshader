shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, unshaded;

uniform vec4 outline_color : source_color = vec4(1.0, 0.8, 0.0, 1.0);
uniform float outline_width = 1.5;
uniform float outline_intensity = 2.0;

void fragment() {
	vec3 normal = normalize(NORMAL);
	vec3 view = normalize(VIEW);
	float fresnel = 1.0 - abs(dot(normal, view));

	fresnel = pow(fresnel, outline_width);

	ALBEDO = outline_color.rgb;
	ALPHA = fresnel * outline_intensity;
	EMISSION = outline_color.rgb * fresnel * outline_intensity;
}