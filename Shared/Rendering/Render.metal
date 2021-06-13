//
//  Render.metal
//  Cellua
//
//  Created by Markus Moenig on 12/6/21.
//

#include <metal_stdlib>
using namespace metal;

#import "Metal.h"

float hash21(float2 p) {
    float3 p3  = fract(float3(p.x, p.y, p.x) * 0.1031);
    p3 += dot(p3, float3(p3.y, p3.z, p3.x) + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}
    
/// Resets the value texture by initializing it with some pseudo-random hash values
kernel void resetTexture(texture2d<half, access::write>  valueTexture  [[texture(0)]],
                         uint2 gid                       [[thread_position_in_grid]])
{
    //float2 size = float2(valueTexture.get_width(), valueTexture.get_height());
    float2 uv = float2(float(gid.x), float(gid.y));
    
    float v = round(hash21(uv));
    
    half4 color = half4(v);
    valueTexture.write(color, gid);
}

uint2 wrap(int2 gid, int2 size) {
    return uint2((gid + size) % size);
}

/// Resets the value texture by initializing it with some pseudo-random hash values
kernel void evalShapes(texture2d<half, access::read>  valueTexture      [[texture(0)]],
                       texture2d<half, access::write> valueTextureOut   [[texture(1)]],
                       constant int *shapeA                             [[buffer(2)]],
                       uint2 gid                                        [[thread_position_in_grid]])
{
    int2 size = int2(valueTexture.get_width(), valueTexture.get_height());

    int count = 0;
    
    int loop = 0;
    int2 g = int2(gid.x, gid.y);
    
    for (int y = 0; y < 9; y += 1) {
        for (int x = 0; x < 9; x += 1) {
            
            if (shapeA[loop] == 1) {
                
                int2 offset = int2(x - 4, y - 4);
                
                count += valueTexture.read(wrap(g -  offset, size)).x;
            }
            
            loop += 1;
        }
    }

    int current = valueTexture.read(gid).x;
    half result = ((count == 2 && current == 1) || (count == 3)) ? 1.0 : 0.0;
    
    valueTextureOut.write(result, gid);
}
