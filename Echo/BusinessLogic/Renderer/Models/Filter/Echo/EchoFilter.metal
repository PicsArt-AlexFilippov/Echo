//
//  EchoFilter.metal
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

#include <metal_stdlib>
using namespace metal;

//#include "Structures.metal"
//#include "ShaderTypes.h"

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

uint textureIndex(int startingPosition, int framesCount, int index) {
    return (startingPosition - index + framesCount) % framesCount;
}

float luminanceRGBFloat(half3 rgb) {
    const float3 W = float3(0.2125, 0.7154, 0.0721);
    return dot(float3(rgb), W);
}

float luminanceRGBFloat(float3 rgb) {
    const float3 W = float3(0.2125, 0.7154, 0.0721);
    return dot(float3(rgb), W);
}

float2 opticalFlow(texture2d_array<half, access::read> texture, uint2 uv, uint posInTex, uint cache)
{
    const float uForce = 4.;
    const float uOffset = 16.;
    const float uLambda = 0.1;
    const float uThreshold = 0.01;

    const float2 uInverse = float2(1.,1.);
    
    
    uint2 pixelOffset = uint2(uOffset);
    uint2 offX = uint2(pixelOffset.x,0);
    uint2 offY = uint2(0,pixelOffset.y);
    
    // difference calculation
    
//    float texDiff = luminanceRGBFloat(texture.read(uv, textureIndex(posInTex, texture.get_array_size(), 0)).rgb) - luminanceRGBFloat(texture.read(uv, textureIndex(posInTex, texture.get_array_size(), 0)).rgb);
    float texDiff = luminanceRGBFloat(texture.read(uv, textureIndex(posInTex, texture.get_array_size(), texture.get_array_size() - 1)).rgb) - luminanceRGBFloat(texture.read(uv, textureIndex(posInTex, texture.get_array_size(), 0)).rgb);
    // gradient calculation
    
    float gradX = luminanceRGBFloat(texture.read(uv + offX, textureIndex(posInTex, cache, cache-1)).rgb) - luminanceRGBFloat(texture.read(uv - offX, textureIndex(posInTex, cache, cache-1)).rgb);
    gradX += luminanceRGBFloat(texture.read(uv + offX, textureIndex(posInTex, cache, 0)).rgb) - luminanceRGBFloat(texture.read(uv - offX, textureIndex(posInTex, cache, 0)).rgb);
    
    float gradY = luminanceRGBFloat(texture.read(uv + offY, textureIndex(posInTex, cache, cache-1)).rgb) - luminanceRGBFloat(texture.read( uv - offY, textureIndex(posInTex, cache, cache-1)).rgb);
    gradY += luminanceRGBFloat(texture.read(uv + offY, textureIndex(posInTex, cache, 0)).rgb) - luminanceRGBFloat(texture.read(uv - offY, textureIndex(posInTex, cache, 0)).rgb);
    
    float gradMag = sqrt((gradX*gradX)+(gradY*gradY)+uLambda);
    
    float vx = texDiff*(gradX/gradMag);
    float vy = texDiff*(gradY/gradMag);
    
    float2 flow = float2(0.0);
    flow.x = -vx * uInverse.x;
    flow.y = -vy * uInverse.y;
    
    // apply treshold
    float strength = length(flow);
    if (strength * uThreshold > 0.0) {
        if (strength < uThreshold) {
            flow = float2(0.0);
        }
        else {
            strength = (strength - uThreshold) / (1.0 - uThreshold);
            flow = normalize(flow) * float2(strength);
        }
    }
    
    // apply force
    flow *= float2(uForce);
    return float2(flow);
}



kernel void motionField(texture2d_array<half, access::read> inTexture [[texture(0)]],
                        texture2d<half, access::write> outTexture [[texture(1)]],
                        device const unsigned int *positionInTexture [[buffer(0)]],
                        uint2 gid [[thread_position_in_grid]]) {
    float2 uv = float2(gid) / float2(outTexture.get_width(), outTexture.get_height());
    uint2 res = uint2(inTexture.get_width(), inTexture.get_height());
    float aspect = float(outTexture.get_width()) / float(outTexture.get_height());
    float2 of = opticalFlow(inTexture, gid, *positionInTexture, inTexture.get_array_size());
    outTexture.write(half4(of.x, of.y, 0.,1.), gid);
}

fragment half4 Audio(TextureMappingVertex mappingVertex [[ stage_in ]],
                     texture2d<half> origTexture [[texture(0)]],
                     sampler sampler [[sampler(0)]]) {
    float2 uv = mappingVertex.textureCoordinate;
   
    half4 col = origTexture.sample(sampler, uv);
    
    return col;
}

