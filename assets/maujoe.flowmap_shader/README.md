# Flow map Shader

A basic flow map material shader for Godot 3.x.
Flow maps are a texture based way to make detailed texture animations (e.g. water, lava, fluids...) or texture distortions.

Video: https://youtu.be/kkZJ9SBH_24


# How it works

Basically it uses 2 channels of a texture to move texture coordinates along the x and y axes.
Each channel controls one axis. A channel color value of 0.5 means no flow, a value greater than 0.5 moves the coordinates along one direction of an axis  and a value smaller than 0.5 moves it to the opposite direction.
So with the right values textures can be moved in all directions and that for each location individually unlike simple uv scroll. River example:

<img src="demo/textures/flowmap.png" width="250">

But there are also some limitations, so to avoid big texture scratches/artifacts in the long run there are two repeating layers which are offseted and blended together. Also to minimize the pulsing effect a noise texture can be used to add some random offset.

For references and more details about flow maps see below.


## How to create flow maps
Painting flow maps manually is tricky but there are some programs to create them.

#### Software to create flow maps
- Flowmap Painter by Teck Lee Tan: http://teckartist.com/?page_id=107
- Flow Field Editor by Stanislaw Adaszewski: https://github.com/sadaszewski/flowed
- Flowmap generator by Superposition Games (Paid): http://www.superpositiongames.com/ (Haven't tested it but looks powerfull)
- It's also possible to create flow maps from whole simulations with the Software Houdini but I haven't done this yet.
- ...


## Asset Info

#### Demo
There are two example scenes in the demo folder that demostrate how to use flow maps for basic water and lava materials.

#### Shader variations
There are multiple shader variations for different requirements that are marked via file names:

- "basic_flowmap_material.shader" - Default shader.
- "displace" - Allows displacement via height map. (WIP doens't update normals but works ok with small displace scale).
- "per_vertex" - Calculate flow per vertex instead of per per pixel.
- "vertex_color" - Use the vertex color instead of a flow map.

#### Performance Optimizitions / Customization:
By default all textures are affected by the flowmap. The shader can be optimized/customized by deleting/replacing unnecessary shader code (with the default one).


## Shader settings

Many shader settings are equivalent to godot spatial material editor and are explained in the Godot docs http://docs.godotengine.org/en/3.0.
The shader specific settings can be found below.

#### Flow map Settings
- sampler2D texture_flow_map - The flow map texture that represents a 2D vector field to animate the uv coordinates.
- vec4 flow_map_x_channel - The texture channel to animate along the x-axis. Default value is (1.0, 0.0, 0.0, 0.0) (red channel).
- vec4 flow_map_y_channel - The texture channel to animate along the y-axis. Default value is (0.0, 1.0, 0.0, 0.0) (green channel).
- vec2 channel_flow_direction - Set the flow directions of the x and y axes. Default value is (1, -1).
- float blend_cycle - The "duration * 2" until the texture animation start over. Default value is 1.0.
- float cycle_speed - The speed of the blend cycle. Default value is 1.0.
- float flow_speed - The speed/direction of the flow independent from the blend cycle (can cause distortions). Default value is 1.0.
- float flow_normal_influence - A factor to control how much the flow speed influences the normal scale. Default value is 0.0.


- sampler2D texture_flow_noise - A noise texture to offset uv coordinates and minimize pulsing effects (Optional).
- vec4 noise_texture_channel - The texture channel.
- float flow_noise_size - The scale of the noise texture. Default value is vec2(1.0, 1.0).
- float flow_noise_influence - The influence factor of the noise texture. Default value is 0.5.

#### Displace Settings (displace version only)
- sampler2D texture_displace - A height map texture used for displacement.
- vec4 displace_texture_channel - The texture channel used for the displacement.
- float displace_scale - The scale of the dislpacement.
- float flow_displace_influence - A factor to control how much the flow speed influence the displace scale. Default value is 0.0.


## References / More about Flow maps
Valve:

https://steamcdn-a.akamaihd.net/apps/valve/2010/siggraph2010_vlachos_waterflow.pdf
https://developer.valvesoftware.com/wiki/Water_(shader)#Flowmaps
https://steamcdn-a.akamaihd.net/apps/valve/2011/gdc_2011_grimes_nonstandard_textures.pdf

Naughty Dog:

https://cgzoo.files.wordpress.com/2012/04/water-technology-of-uncharted-gdc-2012.pdf

Other:

https://mtnphil.wordpress.com/2012/08/25/water-flow-shader/
http://graphicsrunner.blogspot.de/2010/08/water-using-flow-maps.html
http://phill.inksworth.com/tut.php
