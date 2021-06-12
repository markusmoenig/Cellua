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
    
    half4 color = half4(hash21(uv));
    valueTexture.write(color, gid);
}
