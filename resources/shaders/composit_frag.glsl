#version 150

//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
// 

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

vec4 permute(vec4 x) {
  return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}


float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
    + i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

float snoise(vec3 v)
{ 
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
  i = mod289(i); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
}

uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform sampler2D texture4;

uniform mat4 invViewMatrix;

uniform vec3 camPos;
uniform vec2 camRange = vec2(0.1,100.0);
uniform float camRatio = 1024.0/768.0;
uniform float camFov = 60.0;

uniform vec3 noiseScale = vec3(20,5,20);

in vec2 TexCoord;

out vec3 out_Radiance;

const float HALF_RAD = 3.14159265/360.0;

// Linearize Depth into screen space coordinates [-1,1] (near, far)
float linearizeDepth(float d)
{
  float z_n = 2.0 * d - 1.0;
  return -2.0 * camRange.x * camRange.y / (camRange.y + camRange.x - z_n * (camRange.y - camRange.x));
}

vec3 calcScreenSpaceCoords(float d)
{
  float top = tan(camFov * HALF_RAD);
  float right = camRatio * top;
  vec2 adjustProj = vec2(-right, top);

  vec3 screenCoord = vec3((TexCoord.x-0.5) * 2.0, (-TexCoord.y+0.5) * 2.0, linearizeDepth(d));

  screenCoord.xy *= screenCoord.z * adjustProj;

  return screenCoord;
}

float sampleNoise( vec3 coord ) {

  float n = 0.0;

  coord *= noiseScale;

  //n += 0.7    * abs( snoise( coord ) );
  //n = 0.5;
  n += 0.5   * abs( snoise( coord * 2.0 ) );
  n += 0.25  * abs( snoise( coord * 4.0 ) );
  //n += 0.125 * abs( snoise( coord * 8.0 ) );

  return n;

}

float aastep(float threshold, float value)
{
  float afwidth = 0.7 * length(vec2(dFdx(value), dFdy(value)));
  return smoothstep(threshold-afwidth, threshold+afwidth, value);
}


const vec3 upperColor = vec3(0.0,0.0,0.5);
const vec3 lowerColor = vec3(0.3,0.0,0.0);

vec3 colorMap(float val)
{
  return val * lowerColor + (1.0 - lowerColor) * upperColor;
}

vec3 sampleVein(vec3 coord, vec2 texCoord, float veinThickness, float frequency, float offset)
{
  float halfVeinThickness = veinThickness * 0.5;
  float val = frequency + snoise(coord*70);
  vec3 value = vec3( aastep(0.4,abs(fract(val) - offset)) );
  value = vec3(snoise(coord*30));
  return value;
}

void main(void)
{
  float frontDepth = texture(texture0, TexCoord).r;
  vec3 albedo = texture(texture1, TexCoord).rgb;
  vec3 frontLight = texture(texture2, TexCoord).rgb;
  vec3 backLight = texture(texture3, TexCoord).rgb;
  vec4 normalXYandST = texture(texture4, TexCoord);

  vec3 screenCoord;

  screenCoord = calcScreenSpaceCoords(frontDepth);
  vec3 worldFrontCoord = vec3(invViewMatrix * vec4(screenCoord,1.0));

  const int SAMPLES = 3;
  const float WEIGHT_SCALE = 0.5;
  const float stepsize = 0.010;

  vec3 direction = normalize(worldFrontCoord - camPos);

  float noise = 0.0;
  float weight = 0.7;
  vec3 sampleCoord = worldFrontCoord + stepsize * direction;

  if(weight > 0.0)
  {
    for(int i=0; i<SAMPLES ; ++i)
    {
      noise += weight * sampleNoise( sampleCoord );
      weight *= WEIGHT_SCALE;
      sampleCoord += stepsize * direction;
    }
  }

  out_Radiance = vec3(0.0);

  const float backLightNoiseWeight = 1.0;
  const float frontLightNoiseWeight = 0.2;

  out_Radiance += (backLightNoiseWeight * noise + ( 1.0 - backLightNoiseWeight ) ) * backLight;
  out_Radiance += (frontLightNoiseWeight * noise +  ( 1.0 - frontLightNoiseWeight ) ) * frontLight;
  out_Radiance *= albedo;

  //out_Radiance = vec3(noise);
}