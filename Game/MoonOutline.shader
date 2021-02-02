shader_type canvas_item;

uniform float time = 0.0;

void fragment()
{
	// If the pixel is outside the inner circle, discard it.
	if (distance(vec2(0.5, 0.5), UV) > 0.5) discard;
	// Use a constantly changing color from green to blue to yellow
	COLOR = vec4(sin(time), 1.0, cos(time), 1.0);
}