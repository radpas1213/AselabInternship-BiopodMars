shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D new_pallete;
uniform float intensity = 1.0;

float invert_zero_to_one(float num) {
	return 1.0 - num;
}

vec4 threshold(vec4 initial, vec4 final){
	return initial * invert_zero_to_one(intensity) + final * intensity;
}

void fragment() {
	vec4 rgba = texture(TEXTURE, UV);
	vec4 final_color = texture(new_pallete, vec2(rgba.r, rgba.g));
	final_color.a = rgba.a;
	
	//COLOR = threshold(rgba, final_color);
	COLOR = final_color;
	//COLOR = rgba;
}