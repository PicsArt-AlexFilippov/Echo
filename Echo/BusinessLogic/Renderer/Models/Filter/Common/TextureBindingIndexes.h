//
//  TextureBindingIndexes.h
//  MetalRenderCamera
//
//  Created by Tigran Astvatsatryan on 8/20/19.
//  Copyright © 2019 Defekt. All rights reserved.
//

#ifndef TextureBindingIndexes_h
#define TextureBindingIndexes_h

#include <simd/simd.h>


typedef struct {
    int mode;
    int over;
    int type;
} MaskData;


#define MASK_TEXTURE_INDEX 29
#define SEGMENTATION_TEXTURE_INDEX 30

#define MASK_DATA_INDEX 28
#define SEGMENTATION_MODE_INDEX 29
#define SEGMENTATION_LAST_TEXTURE_INDEX_INDEX 30

#endif /* TextureBindingIndexes_h */
