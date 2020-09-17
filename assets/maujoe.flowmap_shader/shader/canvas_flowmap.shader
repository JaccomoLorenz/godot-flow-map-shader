shader_type canvas_item;
render_mode blend_mix;
uniform float flow_speed : hint_range(-3.,3.) = 1.;
uniform sampler2D flow_map : hint_normal;

uniform sampler2D flow_noise : hint_normal;
uniform vec2 flow_noise_size = vec2(1.0, 1.0);
uniform float flow_noise_influence : hint_range(0.,1.) = 0.5;
uniform vec4 noise_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);

uniform vec4 flow_map_x_channel = vec4(1.0, 0.0, 0.0, 0.0);
uniform vec4 flow_map_y_channel = vec4(0.0, 1.0, 0.0, 0.0);
uniform vec2 channel_flow_direction = vec2(1.0, -1.0);
uniform float blend_cycle = 1.0;
uniform float cycle_speed = 1.0;

void fragment() {
	
	// UV flow  calculation
	/****************************************************************************************************/
	float half_cycle = blend_cycle * 0.5;

	// Use noise texture for offset to reduce pulsing effect
	float offset = dot(texture(flow_noise, UV * flow_noise_size), noise_texture_channel) * flow_noise_influence;

	float phase1 = mod(offset + TIME * cycle_speed, blend_cycle);
	float phase2 = mod(offset + TIME * cycle_speed + half_cycle, blend_cycle);

	vec4 flow_tex = texture(flow_map, UV);
	vec2 flow;
	flow.x = dot(flow_tex, flow_map_x_channel) * 2.0 - 1.0;
	flow.y = dot(flow_tex, flow_map_y_channel) * 2.0 - 1.0;
	flow *= normalize(channel_flow_direction);

	// Blend factor to mix the two layers
	float blend_factor = abs(half_cycle - phase1)/half_cycle;

	// Offset by halfCycle to improve the animation for color (for normalmap not absolutely necessary)
	phase1 -= half_cycle;
	phase2 -= half_cycle;

	vec2 layer1 = flow * phase1 + UV;
	vec2 layer2 = flow * phase2 + UV;
	
	COLOR = mix(
		texture(TEXTURE,layer1),
		texture(TEXTURE,layer2),
		blend_factor
	);
}