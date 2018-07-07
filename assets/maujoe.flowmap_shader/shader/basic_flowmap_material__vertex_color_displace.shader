shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_white;
uniform vec4 metallic_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
uniform sampler2D texture_roughness : hint_white;
uniform vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
uniform sampler2D texture_emission : hint_black_albedo;
uniform vec4 emission : hint_color;
uniform float emission_energy;
uniform sampler2D texture_refraction;
uniform float refraction : hint_range(-16,16);
uniform vec4 refraction_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset;
uniform float proximity_fade_distance;
uniform float distance_fade_min;
uniform float distance_fade_max;

// Normalmap
uniform sampler2D texture_normal : hint_normal;
uniform float normal_scale : hint_range(-16,16);
uniform float flow_normal_influence : hint_range(0, 1);

// Displacemap
uniform sampler2D texture_displace : hint_black;
uniform vec4 displace_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
uniform float displace_scale;
uniform float flow_displace_influence : hint_range(0, 1);
uniform float displace_cycle_speed = 1.0;
uniform float displace_speed = 1.0;
uniform float displace_offset;

// Flow uniforms
uniform vec4 flow_map_x_channel = vec4(1.0, 0.0, 0.0, 0.0);
uniform vec4 flow_map_y_channel = vec4(0.0, 1.0, 0.0, 0.0);
uniform vec2 channel_flow_direction = vec2(1.0, -1.0);
uniform float blend_cycle = 1.0;
uniform float cycle_speed = 1.0;
uniform float flow_speed =  0.5;

uniform sampler2D texture_flow_noise;
uniform vec4 noise_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
uniform vec2 flow_noise_size = vec2(1.0, 1.0);
uniform float flow_noise_influence = 0.5;


varying vec2 base_uv;
varying vec2 layer1;
varying vec2 layer2;
varying float  blend_factor;
varying float normal_influence;

void vertex() {
	base_uv = UV * uv_scale.xy + uv_offset.xy;

		// UV flow  calculation
	/****************************************************************************************************/
	float half_cycle = blend_cycle * 0.5;

	// Use noise texture for offset to reduce pulsing effect
	float offset = dot(texture(texture_flow_noise, UV * flow_noise_size), noise_texture_channel) * flow_noise_influence;

	float phase1 = mod(offset + TIME * cycle_speed, blend_cycle);
	float phase2 = mod(offset + TIME * cycle_speed + half_cycle, blend_cycle);

	vec4 flow_tex = COLOR;
	vec2 flow;
	flow.x = dot(flow_tex, flow_map_x_channel) * 2.0 - 1.0;
	flow.y = dot(flow_tex, flow_map_y_channel) * 2.0 - 1.0;
	flow *= normalize(channel_flow_direction);

	// Make flow influence on the normalmap / displace strenght adjustable (optional)
	float flow_strength = dot(abs(flow), vec2(1.0, 1.0)) * 0.5;
	normal_influence = mix(1.0, flow_strength, flow_normal_influence);
	float displace_influence = mix(1.0, flow_strength, flow_displace_influence);

	// Blend factor to mix the two layers
	blend_factor = abs(half_cycle - phase1)/half_cycle;

	// Offset by halfCycle to improve the animation for color (for normalmap not absolutely necessary)
	phase1 -= half_cycle;
	phase2 -= half_cycle;

	// Multiply with scale to make flow speed independent from the uv scaling
	vec2 displace_flow = flow * displace_speed * uv_scale;
	flow *= flow_speed * uv_scale;

	layer1 = flow * phase1 + base_uv;
	layer2 = flow * phase2 + base_uv;
	/****************************************************************************************************/

	// Displacement (WIP - works ok for small displace scale)
	// Use own phases for displacement for better control
	float disp_phase1 = mod(offset + TIME * displace_cycle_speed, blend_cycle);
	float disp_phase2 = mod(offset + TIME * displace_cycle_speed + half_cycle, blend_cycle);
	float disp_blend_factor = abs(half_cycle - disp_phase1)/half_cycle;
	float voffset = dot(mix(texture(texture_displace, displace_flow * disp_phase1 + base_uv), texture(texture_displace, displace_flow * disp_phase2 + base_uv), disp_blend_factor), displace_texture_channel) * displace_scale * displace_influence + displace_offset;
	VERTEX.y += voffset;

	// Todo: recalculating normals
	// (Also creating heightmap value inside shader is maybe more efficient for this purpose)
}

void fragment() {

	// Albedo
	// Mix animated uv layers
	vec4 albedo_tex = mix(texture(texture_albedo, layer1), texture(texture_albedo, layer2), blend_factor);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	// Metallic / Roughness / Specular
	// Mix animated uv layers
	float metallic_tex = mix(dot(texture(texture_metallic, layer1), metallic_texture_channel), dot(texture(texture_metallic, layer2), metallic_texture_channel), blend_factor);
	METALLIC = metallic_tex * metallic;
	float roughness_tex = mix(dot(texture(texture_roughness, layer1), roughness_texture_channel), dot(texture(texture_roughness, layer2), roughness_texture_channel), blend_factor);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;

	// Normalmap
	// Mix animated uv layers
	NORMALMAP = mix(texture(texture_normal, layer1), texture(texture_normal, layer2), blend_factor).rgb;
	NORMALMAP_DEPTH = normal_scale * normal_influence;

	// Refraction
	vec3 ref_normal = normalize(mix(NORMAL,TANGENT * NORMALMAP.x + BINORMAL * NORMALMAP.y + NORMAL * NORMALMAP.z,NORMALMAP_DEPTH));
	// Mix animated uv layers
	vec4 ref_tex = mix(texture(texture_refraction, layer1), texture(texture_refraction, layer2), blend_factor);
	vec2 ref_ofs = SCREEN_UV - ref_normal.xy * dot(ref_tex, refraction_texture_channel) * refraction;
	float ref_amount = 1.0 - albedo.a * albedo_tex.a;
	ALBEDO *= 1.0 - ref_amount;

	// Emission
	// Mix animated uv layers
	vec3 emission_tex = mix(texture(texture_emission, layer1), texture(texture_emission, layer2), blend_factor).rgb;
	EMISSION = (emission.rgb+emission_tex) * emission_energy;
	EMISSION += textureLod(SCREEN_TEXTURE, ref_ofs, ROUGHNESS * 8.0).rgb * ref_amount;

	// Proximity fade / Distance fade
	float depth_tex = textureLod(DEPTH_TEXTURE,SCREEN_UV, 0.0).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth_tex * 2.0 - 1.0, 1.0);
	world_pos.xyz /= world_pos.w;
	ALPHA = 1.0;
	ALPHA *= clamp(1.0 - smoothstep(world_pos.z + proximity_fade_distance, world_pos.z, VERTEX.z), 0.0, 1.0);
	ALPHA *= clamp(smoothstep(distance_fade_min,distance_fade_max,-VERTEX.z), 0.0, 1.0);
}
