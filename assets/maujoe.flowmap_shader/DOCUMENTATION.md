## Asset Info

#### Demo
There are two example scenes in the demo folder that demostrate how to use flow maps for basic water and lava materials.

#### Shader variations
There are multiple shader variations for different requirements that are marked via file names:

- "basic_flowmap_material.shader" - Default shader.
- "displace" - Allows displacement via height map. (WIP Works ok with small displace scale).
- "per_vertex" - Calculate flow per vertex instead of per per pixel.
- "vertex_color" - Use the vertex color instead of a flow map.

#### Performance Optimizitions:
- The shader allows to animate all textures to give much possibilities. So the performance can be improved by deleting (replace) unnecessary (not used) shader code.


## Shader settings

The many shader settings are equivalent to godot spatial material editor and are explained in the Godot docs http://docs.godotengine.org/en/3.0.
The shader specific settings can be found below.

#### Flow map Settings
- sampler2D texture_flow_map - The flow map texture that represents a 2D vector field to animate the uv coordinates.
- vec4 flow_map_x_channel - The texture channel to animate along the x-axis. Default value is (1.0, 0.0, 0.0, 0.0) (red channel).
- vec4 flow_map_y_channel - The texture channel to animate along the y-axis. Default value is (0.0, 1.0, 0.0, 0.0) (green channel).
- vec2 channel_flow_direction - Set the flow directions of the x and y axes.
- float blend_cycle - The length of one blend cycle of the two layers. Default value is 1.0.
- float cycle_speed - The speed of the blend cycle. Default value is 1.0.
- float flow_speed - The speed of the flow independent from the blend cycle (can cause distortions). Default value is 1.0.
- float speed - The speed/direction of the flow.
- float flow_normal_influence - A factor to control how much the flow speed influence the normal scale. Default value is 0.


- sampler2D texture_flow_noise - A noise texture to offset uv coordinates and minimize pulsing effects (Optional).
- vec4 noise_texture_channel - The texture channel.
- float flow_noise_size - The scale of the noise texture. Default value is vec2(1.0, 1.0).
- float flow_noise_influence - The influence factor of the noise texture. Default value is 0.5.

#### Displace Settings (displace version only)
- sampler2D texture_displace - A height map texture used for displacement.
- vec4 displace_texture_channel - The texture channel used for the displacement.
- float displace_scale - The scale of the dislpacement.
- float flow_displace_influence - A factor to control how much the flow speed influence the displace scale. Default value is 0.
