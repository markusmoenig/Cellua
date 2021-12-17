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

float sdBox(float2 p, float2 b)
{
    float2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

/// Draws the current state into the resultTexture and the next state into valueTextureOut
kernel void evalShapes(texture2d<float, access::read>   valueTexture      [[texture(0)]],
                       texture2d<float, access::write>  valueTextureOut   [[texture(1)]],
                       constant float4                  *palette          [[buffer(2)]],
                       texture2d<float, access::write>  resultTexture     [[texture(3)]],
                       uint2                            gid [[thread_position_in_grid]])
{
    int2 size = int2(valueTexture.get_width(), valueTexture.get_height());
    float2 grid = float2(gid.x, gid.y);

    // Draw current state
    
    int scale = 30;

    float4 col = valueTexture.read(gid / scale).x > 0.5 ? float4(1) : float4(0,0,0,1);
    float2 gv = fract(grid / float(scale));
    
    float edge = 0.95 - float(scale) / size.x / 2.0;
    col.rgb = mix(col.rgb, float3(0.5, 0.5, 0.5), max(step(edge, gv.x), step(edge, gv.y)));
    
    resultTexture.write(col, gid);

    // Calculate next state
    
    int num = 0;
    
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            if (x == 0 && y == 0) continue;
            num += valueTexture.read(wrap(int2(gid) + int2(x, y), size)).x > 0.5 ? 1 : 0;

        }
    }
    
    bool alive = valueTexture.read(gid).x > 0.5 ? true : false;
    int next = (alive && num == 2) || num == 3 ? 1 : 0;
    
    valueTextureOut.write(float4(next), gid);
}
