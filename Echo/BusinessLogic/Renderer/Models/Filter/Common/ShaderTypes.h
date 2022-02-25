//
//  ShaderTypes.h
//  MetalRenderCamera
//
//  Created by Vanush Grigoryan on 8/29/19.
//  Copyright © 2019 Defekt. All rights reserved.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef enum SegmentationMode: int {
    kSegmentationModeHuman          = 0,
    kSegmentationModeAllButHuman    = 1,
    kSegmentationModeOff            = 2
} SegmentationMode;

typedef enum BufferIndices {
    kBufferIndexMeshPositions       = 0,
    kBufferIndexMeshGenerics        = 1,
    kBufferIndexInstanceUniforms    = 2,
    kBufferIndexSharedUniforms      = 3,
    kBufferIndexTextureCoordinates  = 4
} BufferIndices;

typedef enum TextureIndices {
    kTextureIndexMeshDecal          = 0,
} TextureIndices;

typedef struct {
    // Camera Uniforms
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    
} SharedUniforms;

typedef struct {
    matrix_float4x4 modelMatrix;
} InstanceUniforms;

#endif /* ShaderTypes_h */
