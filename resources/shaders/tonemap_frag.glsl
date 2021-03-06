#version 150

uniform sampler2D texture0;
uniform sampler2D texture1;

uniform float exposure = 2.2;
uniform float bloom = 0.3;

in vec2 TexCoord;

out vec3 out_frag0;

const float W = 11.2;
 
// http://filmicgames.com/archives/75
vec3 Uncharted2Tonemap(vec3 x)
{
	const float A = 0.15;
	const float B = 0.50;
	const float C = 0.10;
	const float D = 0.20;
	const float E = 0.02;
	const float F = 0.30;

	return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

void main(void)
{
	vec3 texColor = texture(texture0, TexCoord).rgb;
	vec3 bloomColor = vec3(0.0f);

	bloomColor += textureLod(texture1, TexCoord, 0).rgb;
	bloomColor += textureLod(texture1, TexCoord, 1).rgb;
	bloomColor += textureLod(texture1, TexCoord, 2).rgb;
	bloomColor += textureLod(texture1, TexCoord, 3).rgb;
	bloomColor += textureLod(texture1, TexCoord, 4).rgb;

	vec3 whiteScale = 1.0f/Uncharted2Tonemap(vec3(W));
	vec3 final = texColor + bloom * bloomColor;
	vec3 curr = Uncharted2Tonemap(exposure*final);
	vec3 color = curr*whiteScale;

	//out_frag0 = pow(color, vec3(1.0/2.2));
	out_frag0 = color;
}