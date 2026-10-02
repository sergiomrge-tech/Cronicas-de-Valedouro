shader_type canvas_item;
uniform vec4 armor_palette : source_color = vec4(0.25,0.4,0.8,1.0);
uniform float armor_strength = 0.0;
varying vec4 vertex_tint;
void vertex() { vertex_tint = COLOR; }
void fragment() {
	vec4 base = texture(TEXTURE,UV);
	float blue_cloth = smoothstep(0.07,0.20,base.b-max(base.r,base.g));
	float brightness = max(base.r,max(base.g,base.b));
	vec3 dyed = armor_palette.rgb*brightness;
	COLOR = vertex_tint*vec4(mix(base.rgb,dyed,blue_cloth*armor_strength),base.a);
}
