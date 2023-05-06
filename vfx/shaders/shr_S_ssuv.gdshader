shader_type spatial;
render_mode unshaded, depth_draw_opaque;
// Renders a tileable 2D texture to screen, using spatial polygons as a mask.
// Remove blur from textures by unchecking "Detect 3D" and "Filter" in Import.
// Demo: https://github.com/DeerTears/Polygon-Mask-for-2D-Textures/

uniform vec4 color :hint_color = vec4(1);
uniform sampler2D tiling_texture;
uniform float tiling_scale = 1.0;
uniform sampler2D mask_texture;
uniform float mask_scale = 1.0;

const float DEFAULT_SCALE = 8.0;

void fragment() {
	vec2 uv = FRAGCOORD.xy;
	
	vec2 tiling_uv = uv / (DEFAULT_SCALE * tiling_scale * -1.0);
	vec3 tiling_texture_result = texture(tiling_texture, tiling_uv).rgb;
	
	vec2 mask_uv = uv / (DEFAULT_SCALE * mask_scale * -1.0);
	float mask_texture_result = texture(mask_texture, mask_uv).a;
	
	ALBEDO = tiling_texture_result * color.rgb;
	ALPHA = mask_texture_result;
}
