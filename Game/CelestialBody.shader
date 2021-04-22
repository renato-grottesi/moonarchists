shader_type canvas_item;
uniform float grot = 0.0; // [-PI, +PI]

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(vec2(c, s), vec2(-s, c));
	return m * v;
}

void fragment()
{
	COLOR = texture(TEXTURE, UV);

	if (COLOR.a > 0.5)
	{
		vec2 diff = vec2(0.5, 0.5) - UV;
		diff = rotate(diff, grot);
		if(diff.x < 0.0)
		{
			COLOR.rgb*=0.5;
		}
	}
}