//
//  Structures.metal
//  Metal Camera
//
//  Created by Vanush Grigoryan on 11/17/17.
//  Copyright © 2017 Defekt. All rights reserved.
//

//  EASINGS
float easingBackIn(float t);
float easingBounceOut(float t);
float easingBackOut(float t);
float easingBounceInOut(float t);
float easingBounceIn(float t);
float easingCircularInOut(float t);
float easingCircularIn(float t);
float easingCircularOut(float t);
float easingCubicInOut(float t);
float easingCubicIn(float t);
float easingCubicOut(float t);
float easingElasticInOut(float t);
float easingElasticIn(float t);
float easingElasticOut(float t);
float easingExponentialInOut(float t);
float easingExponentialIn(float t);
float easingExponentialOut(float t);
float easingQuadraticInOut(float t);
float easingQuadraticIn(float t);
float easingQuadraticOut(float t);
float easingQuarticInOut(float t);
float easingQuarticIn(float t);
float easingQuarticOut(float t);
float easingQinticInOut(float t);
float easingQinticIn(float t);
float easingQinticOut(float t);
float easingSineInOut(float t);
float easingSineIn(float t);
float easingSineOut(float t);
float easingLinear(float t);

// BLENDINGS

half3 blendAverage(half3 base, half3 blend);
half3 blendAverage(half3 base, half3 blend, half opacity);
half blendColorBurn(half base, half blend);
half3 blendColorBurn(half3 base, half3 blend);
half3 blendColorBurn(half3 base, half3 blend, half opacity);
half blendColorDodge(half base, half blend);
half3 blendColorDodge(half3 base, half3 blend);
half3 blendColorDodge(half3 base, half3 blend, half opacity);
half blendDarken(half base, half blend);
half3 blendDarken(half3 base, half3 blend);
half3 blendDarken(half3 base, half3 blend, half opacity);
half3 blendDifference(half3 base, half3 blend);
half3 blendDifference(half3 base, half3 blend, half opacity);
half3 blendExclusion(half3 base, half3 blend);
half3 blendExclusion(half3 base, half3 blend, half opacity);
half blendReflect(half base, half blend);
half3 blendReflect(half3 base, half3 blend);
half3 blendReflect(half3 base, half3 blend, half opacity);
half3 blendGlow(half3 base, half3 blend);
half3 blendGlow(half3 base, half3 blend, half opacity);
half blendOverlay(half base, half blend);
half3 blendOverlay(half3 base, half3 blend);
half3 blendOverlay(half3 base, half3 blend, half opacity);
half3 blendHardLight(half3 base, half3 blend);
half3 blendHardLight(half3 base, half3 blend, half opacity);
half blendVividLight(half base, half blend);
half3 blendVividLight(half3 base, half3 blend);
half3 blendVividLight(half3 base, half3 blend, half opacity);
half blendHardMix(half base, half blend);
half3 blendHardMix(half3 base, half3 blend);
half3 blendHardMix(half3 base, half3 blend, half opacity);
half blendLighten(half base, half blend);
half3 blendLighten(half3 base, half3 blend);
half3 blendLighten(half3 base, half3 blend, half opacity);
half blendLinearBurn(half base, half blend);
half3 blendLinearBurn(half3 base, half3 blend);
half3 blendLinearBurn(half3 base, half3 blend, half opacity);
half blendLinearDodge(half base, half blend);
half3 blendLinearDodge(half3 base, half3 blend);
half3 blendLinearDodge(half3 base, half3 blend, half opacity);
half blendLinearLight(half base, half blend);
half3 blendLinearLight(half3 base, half3 blend);
half3 blendLinearLight(half3 base, half3 blend, half opacity);
half3 blendMultiply(half3 base, half3 blend);
half3 blendMultiply(half3 base, half3 blend, half opacity);
half3 blendNegation(half3 base, half3 blend);
half3 blendNegation(half3 base, half3 blend, half opacity);
half3 blendNormal(half3 base, half3 blend);
half3 blendNormal(half3 base, half3 blend, half opacity);
half3 blendPhoenix(half3 base, half3 blend);
half3 blendPhoenix(half3 base, half3 blend, half opacity);
half blendPinLight(half base, half blend);
half3 blendPinLight(half3 base, half3 blend);
half3 blendPinLight(half3 base, half3 blend, half opacity);
half blendScreen(half base, half blend);
half3 blendScreen(half3 base, half3 blend);
half3 blendScreen(half3 base, half3 blend, half opacity);
half blendSoftLight(half base, half blend);
half3 blendSoftLight(half3 base, half3 blend);
half3 blendSoftLight(half3 base, half3 blend, half opacity);
half3 blendSubstract(half3 base, half3 blend);
half3 blendSubstract(half3 base, half3 blend, half opacity);
half3 blendSubtract(half3 base, half3 blend);
half3 blendSubtract(half3 base, half3 blend, half opacity);

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#import "FiltersCacheSizes.h"
#import "TextureBindingIndexes.h"

#ifndef STRUCTURES
#define STRUCTURES
#define deg2rad (M_PI_F / 180.0)
#define rad2deg (180.0/M_PI_F)
#define sf(x)     smoothstep( .1, .9 -step(.4,fabs(x-.5)) , x-step(.9,x) )
#define sfract(x) sf(fract(x))
#define GOLDEN_ANGLE 2.39996

typedef struct {
    float4 renderedCoordinate [[position]];
    half4 color;
    float2 textureCoordinate;
    float pointSize [[point_size]];
    uint orientation;
    uint vertexId;
    bool mirroring;
    bool isBackground;
    float customAttr;
    float3 normal;
} TextureMappingVertex;

struct Light {
    float4 position;
    float range;
    float innerConeAngle;
    float outerConeAngle;
    float3 spotDirection;
    float intensity;
    half3 color;
};

struct palette {
    half3 a;
    half3 b;
    half3 c;
    half3 d;
    half mult;
};


struct Material {
    half3 metallicRoughnessValues;
    
};

enum order : uint{
    xyz = 0,
    xzy = 1,
    yxz = 2,
    yzx = 3,
    zxy = 4,
    zyx = 5
};

struct ParticleVertex{
    float3 position [[attribute(0)]];
    float3 normal  [[attribute(1)]];
    float2 texCoord  [[attribute(2)]];
};
    
uint textureIndex(int startingPosition, int framesCount, int index);
half luminanceRGB(half3 rgb);
float luminanceRGBFloat(float3 rgb);
float luminanceRGBFloat(half3 rgb);
half luminance(half3 rgb,half3 chan, bool bw);
half3 levelChannel(half3 value, half offset, half mult);
float rand(float2 co, int dir);
float randPixel(float2 co);
half3 brightness(half3 _col);
float random(uint2 p);
float noise(float2 p);
float noise(float2 p, int oct);
float2 customNoise(float2 pos);
float2 hash(float2 p);
half3 sobel_edge(texture2d_array<half> texture, float2 uv, int posInTex);
half4 sobel_edge2(texture2d_array<half> texture, float2 uv, int posInTex);
half3 sobel_edge(texture2d<half, access::read> texture, uint2 uv);
half3 sobel_edge(texture2d_array<half, access::read> texture, uint2 uv, int index, int cache);
half3 corner_detection(texture2d<half, access::read> texture, uint2 uv, uint2 offset);
half3 corner_detection(texture2d<half> texture, float2 uv, float2 offset);
half3 corner_detection(texture2d_array<half, access::read> texture, int index, uint2 uv, uint2 offset);
float2 rotate(float2 uv1, float degree);
float2 rotate(float2 uv, float degree, float2 aspect);
float L(float2 fc,float dx,float dy,texture2d<half> texture, sampler sampler, float2 res);
half4 T0(float2 fc,float dx,float dy, texture2d<half> feedback, int angle, sampler sampler, float2 res);
half4 T1(float2 fc,float dx,float dy, texture2d<half> texture, sampler sampler, float2 res);
float2 uvGradient(int2 fc, texture2d<half, access::read> texture);
float2 uvGradient(uint2 fc, texture2d_array<half, access::read> texture, uint frame);
half3 saturation(half3 rgb, half adjustment);
float2 opticalFlow(uint2 wh, texture2d_array<half> texture, sampler sampler, float2 uv, uint posInTex);
float2 opticalFlow(texture2d_array<half, access::read> texture, uint2 uv, uint posInTex, uint cache);
half3 rgb2hsv(half3 c);
half3 hsv2rgb(half3 c);
float3 random3(float3 c);
float simplex3d(float3 p);
half3 palette( half t, half3 a, half3 b, half3 c, half3 d );
float band(float t, float start, float end, float blur);
float band(float t, float start, float end, float startBlur, float endBlur);
template <class T> inline T band(T t, T start, T end, T blur){
    T step1 = smoothstep(start - blur, start + blur, t);
    T step2 = smoothstep(end + blur, end - blur, t);
    return min(step1, step2);
}

template <class T> inline T remap(T value, T low1, T high1, T low2, T high2){
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
}

float asr(float t, float start, float end, float (*easing1) (float) = easingLinear, float (*easing2) (float) = easingLinear);
half triangle (float2 uv, int type, float angle);
float4 noised(float3 x);
float4x4 rotMatXYZ(float xRot, float yRot, float zRot);
float fBm(float3 p, float octaves, float lacunarity, float gain);
float2 snoiseVec2( float3 x, float octaves, float lacunarity, float gain);
float2 curlNoise( float3 p, float octaves, float lacunarity, float gain);
float3x3 calcLookAtMatrix(float3 origin, float3 target, float roll);
float findAngle(float2 origin, float2 target);
float4x4 projFov (float fov, float aspect, float nearZ, float farZ);
template <class T> inline T map(T value, T inMin, T inMax, T outMin, T outMax) {
    return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}
float4 voronoi(float2 x, float time);
template <class T> inline T over (T input1, T input2) {
    return input2 * (1.0 - input1.a) + input1;
}
template <class T> inline T under (T input1, T input2) {
    return input1 * (1.0 - input2.a) + input2;
}
template <class T, class U> inline T palette( U t, T a, T b, T c, T d )
{
    return a + b * cos( 6.28318 * (c * t + d) );
}
    
template <class T> inline T smin3(T a, T b, float k)
{
    T x = exp(-k * a);
    T y = exp(-k * b);
    return (a * x + b * y) / (x + y);
}

template <class T> inline T smax2(T a, T b, float k)
{
    return smin3(a, b, -k);
}

float4x4 rotation3dX(float x);
float4x4 rotation3dY(float y);
float4x4 rotation3dZ(float z);
float4x4 rotation3d(float x, float y, float z, uint order);
float4x4 perspective(float fovy, float aspect, float zNear, float zFar);
float4x4 translation3d(float x, float y, float z);
float4x4 scale3d(float x, float y, float z);
float4 spring(float4 fb, float2 of);
half frameDif(texture2d_array<half, access::read> inTexture, uint2 uv, uint index, uint cache);
half frameDif(texture2d_array<half, access::sample> inTexture, float2 uv, uint index, uint cache, sampler sampler);
float median(float r, float g, float b);
half3 overlay(half3 base, half3 blend);
half blendLinearBurn(half base, half blend);
half3 blendLinearBurn(half3 base, half3 blend);
half3 blendLinearBurn(half3 base, half3 blend, half opacity);
half blendLinearDodge(half base, half blend);
half3 blendLinearDodge(half3 base, half3 blend);
half3 blendLinearDodge(half3 base, half3 blend, half opacity);
half blendLinearLight(half base, half blend);
half3 blendLinearLight(half3 base, half3 blend);
half3 blendLinearLight(half3 base, half3 blend, half opacity);
half blendScreen(half base, half blend);
half3 blendScreen(half3 base, half3 blend);
half3 blendScreen(half3 base, half3 blend, half opacity);
half4 blur9(sampler sampler, texture2d<half> texture, float2 uv, float2 resolution, float2 direction);
half4 blur9(sampler sampler, texture2d_array<half> texture, float2 uv, float2 resolution, float2 direction, uint index);
half4 blur(sampler sampler,texture2d_array<half> texture, float2 uv, uint index, float blurSize, float sigma, float2 texOffset);
half4 blur(sampler sampler, texture2d_array<half> texture, float2 uv, uint index, float2 dir, float sigma, int radius);
half4 blur(sampler sampler, texture2d<half> texture, float2 uv, float2 res, float blurSize, float sigma, float2 texOffset);
half4 boxBlur(sampler sampler, texture2d_array<half> texture, float2 uv, uint index, float blurSize, int radius, float2 dir);
half4 boxBlur(sampler sampler, texture2d<half> texture, float2 uv, int radius, float2 dir);
//half4 dirBlur(sampler sampler, texture2d<half> texture, float2 uv, float2 angle, float strength, int samples);
//float4 dirBlur(sampler sampler, texture2d<float> texture, float2 uv, float2 angle, float strength, int samples, float4 channelMask);
float smin(float a, float b, float k);
half4 quadColorVariation (float2 center, float size, texture2d<half, access::read> texture);
float getBayerFromCoordLevel(float2 pixelpos);
float4 streak(sampler sampler, texture2d<float> source, float2 uv, float2 pixelSize, float2 dir, int samples, float attenuation, int iteration);
half generate_seed(uint2 uv, texture2d<half, access::read> texture, float threshold);
half convolve(float krn[9], half4 color_matrix[9]);
float convolve(float krn[9], float4 color_matrix[9]);
half emboss(float2 uv, texture2d<half> texture, sampler sampler, float2 width);
float emboss(float2 uv, texture2d<float> texture, sampler sampler, float2 width);
//half4 circle_bokeh(sampler sampler, texture2d<half> texture, float2 uv, float radius, float angle1, float angle2, uint iterations);
float3 circle_bokeh(sampler sampler, texture2d<float> texture, float2 uv, float radius, float angle1, float angle2, uint iterations);
float4 sharpen(sampler sampler, texture2d<float> tex, float2 coords);
half4 sharpen(sampler sampler, texture2d<half> tex, float2 coords);
template <class T, class U> inline T gradient (T c1, T c2, T c3, U grad) {
    T o = mix(c1, c3, grad);
    U u = 1.0 - fabs(grad * 2.0 - 1.0);
    return mix(o, c2, u);
}
half4 lookup(half4 textureColor, texture2d<half, access::sample> lutTexture, sampler sampler, float2 uv);
#endif

