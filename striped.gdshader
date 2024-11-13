shader_type canvas_item;

uniform vec4 color_gap = vec4(0.25);
uniform vec4 color_stripe = vec4(1.0, 0.75, 0.0, 1.0);
// From https://godotshaders.com/shader/animated-stripes/

uniform float divisions = 24.0; // increase for more stripe density
uniform float stripe_bias = 2.0; // 1.0 means no stripes; 2.0 means stripes and gaps are equal size
uniform float speed = 0.03;
uniform float angle = 0.9854; // in radians

void fragment() {
	float w = cos(angle) * UV.x + sin(angle) * UV.y - speed * TIME;
	if (floor(mod(w * divisions, stripe_bias)) < 0.0001) {
		COLOR = color_gap;
	} else {
		COLOR = color_stripe;
	}
}