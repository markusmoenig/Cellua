//
//  Drawables.h
//  Cellua
//
//  Created by Markus Moenig on 12/6/21.
//

#ifndef Drawables_h
#define Drawables_h

#include <simd/simd.h>

// MARK: Render

typedef struct
{
    int             shape[81];
    
} RenderShape;

// MARK: Drawables

typedef struct
{
    vector_float2   position;
    vector_float2   textureCoordinate;
} VertexUniform;

typedef struct
{
    vector_float2   screenSize;
    vector_float2   pos;
    vector_float2   size;
    float           globalAlpha;

} TextureUniform;

typedef struct
{
    vector_float4   fillColor;
    vector_float4   borderColor;
    float           radius;
    float           borderSize;
    float           rotation;
    float           onion;
    
    int             hasTexture;
    vector_float2   textureSize;
} DiscUniform;

typedef struct
{
    vector_float2   screenSize;
    vector_float2   pos;
    vector_float2   size;
    float           round;
    float           borderSize;
    vector_float4   fillColor;
    vector_float4   borderColor;
    float           rotation;
    float           onion;
    
    int             hasTexture;
    vector_float2   textureSize;

} BoxUniform;

typedef struct
{
    float           time;
    unsigned int    frame;
} MetalData;

typedef struct
{
    float           time;
    unsigned int    frame;
} NoiseData;

#endif /* Drawables_h */
