//
//  Render.metal
//  Cellua
//
//  Created by Markus Moenig on 12/6/21.
//

#include <metal_stdlib>
using namespace metal;

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

uint2 wrap(uint2 gid, uint2 size) {
    return (gid + size) % size;
}

/// Resets the value texture by initializing it with some pseudo-random hash values
kernel void gameOfLife(texture2d<half, access::read>  valueTexture      [[texture(0)]],
                       texture2d<half, access::write> valueTextureOut   [[texture(1)]],
                        uint2 gid                     [[thread_position_in_grid]])
{
    uint2 size = uint2(valueTexture.get_width(), valueTexture.get_height());

    int count = 0;
    
    count += valueTexture.read(wrap(gid - uint2(1, 1), size)).x;
    count += valueTexture.read(wrap(gid - uint2(0, 1), size)).x;
    count += valueTexture.read(wrap(gid - uint2(-1, 1), size)).x;
    
    count += valueTexture.read(wrap(gid - uint2(1, 0), size)).x;
    count += valueTexture.read(wrap(gid - uint2(-1, 0), size)).x;
    
    count += valueTexture.read(wrap(gid - uint2(1, -1), size)).x;
    count += valueTexture.read(wrap(gid - uint2(0, -1), size)).x;
    count += valueTexture.read(wrap(gid - uint2(-1, -1), size)).x;

    int current = valueTexture.read(gid).x;
    half result = ((count == 2 && current == 1) || (count == 3)) ? 1.0 : 0.0;
    
    valueTextureOut.write(result, gid);
}
