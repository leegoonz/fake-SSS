#version 150
 
precision highp float; // needed only for version 1.30

uniform int numLights = 1;

uniform sampler2DShadow texture0;
uniform vec4 lightPos;
uniform vec4 lightDir;
uniform vec4 lightColor = vec4(1,1,1,100);

in vec4 ShadowProj;

in vec3 Normal;
in vec3 WorldPos;

out vec4 out_Color;

const float DegToRad = 3.141592653589793238 / 180.0;

void main(void)
{
	vec3 radiance = vec3(0.0);

	vec3 lightToFrag = (WorldPos - lightPos.xyz);

	float lightDist = length(lightToFrag);

	vec3 L = lightToFrag / lightDist;
	vec3 D = lightDir.xyz;

	float lightOuterAngle = lightPos.w;
	float lightInnerAngle = lightDir.w;

	float cur_angle = dot(L,D);
	float inner_angle = cos(lightInnerAngle * 0.5 * DegToRad);
	float outer_angle = cos(lightOuterAngle * 0.5 * DegToRad);
	float diff_angle = inner_angle - outer_angle;

	// Soft edge on spotlight
	float spot = clamp((cur_angle - outer_angle) /
					diff_angle, 0.0, 1.0);

	float lightLumen = lightColor.a;

	// Light attenuation term
	float att = lightLumen / (lightDist*lightDist);

	if(ShadowProj.w > 0.0)
	{
		//radiance += textureProj(texture0, ShadowProj) * spot * att * lightColor.rgb;
		vec3 coord = ShadowProj.xyz/ShadowProj.w;
		radiance += texture(texture0, coord) * spot * att * lightColor.rgb;
	}

	out_Color = vec4(radiance,1.0);
}