//SHADER ORIGINALY CREADED BY "marmitoTH" FROM GITHUB
//
//GITHUB LINK : https://github.com/marmitoTH/godot-psx-shaders

shader_type spatial; 
render_mode skip_vertex_transform, diffuse_lambert_wrap, specular_disabled, cull_disabled, depth_draw_always;

uniform vec4 color : hint_color = vec4(1.0);
//uniform float vertex_color_amount : hint_range(0.0, 0.5) = 0.5;
uniform sampler2D albedo_tex : hint_albedo;
uniform float resolution = 150;
uniform float affine_texture_mapping_amount : hint_range(0,2);
uniform vec2 uv_scale = vec2(1.0);
uniform vec2 uv_offset = vec2(0.0);

varying vec4 vertex_coordinates;

void vertex() {
	UV = UV * uv_scale + uv_offset;
	
	float vertex_distance = length((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));
	
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float vPos_w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
	VERTEX.xy = vPos_w * floor(resolution * VERTEX.xy / vPos_w) / resolution;
	vertex_coordinates = vec4(UV * VERTEX.z, VERTEX.z, .0);
}

void fragment() {
	vec4 tex = texture(albedo_tex, mix(vertex_coordinates.xy /vertex_coordinates.z, UV.xy, affine_texture_mapping_amount));
	
	ALBEDO = tex.rgb * color.rgb * COLOR.rgb;
//	ALBEDO = mix(tex.rgb * color.rgb, COLOR.rgb, vertex_color_amount);
}