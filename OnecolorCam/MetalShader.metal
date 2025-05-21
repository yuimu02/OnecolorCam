//
//  MetalShader.metal
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/05/21.
//

#include <metal_stdlib>
using namespace metal;

inline half3 rgb2hsb(half r, half g, half b)
{
    half maxc  = max(max(r, g), b);
    half minc  = min(min(r, g), b);
    half delta = maxc - minc;

    half h = 0.0h;
    if (delta > 0.00001h) {
        if (maxc == r)       h = fmod(((g - b) / delta), 6.0h);
        else if (maxc == g)  h = ((b - r) / delta) + 2.0h;
        else                 h = ((r - g) / delta) + 4.0h;
        h /= 6.0h;
        if (h < 0.0h) h += 1.0h;
    }

    half s = (maxc == 0.0h) ? 0.0h : delta / maxc;
    half v = maxc;
    return half3(h, s, v);
}

inline half3 hsb2rgb(half h, half s, half v)
{
    half c  = v * s;
    half h6 = h * 6.0h;
    half x  = c * (1.0h - fabs(fmod(h6, 2.0h) - 1.0h));

    half3 rgb;
    if      (h6 < 1.0h) rgb = half3(c, x, 0.0h);
    else if (h6 < 2.0h) rgb = half3(x, c, 0.0h);
    else if (h6 < 3.0h) rgb = half3(0.0h, c, x);
    else if (h6 < 4.0h) rgb = half3(0.0h, x, c);
    else if (h6 < 5.0h) rgb = half3(x, 0.0h, c);
    else                rgb = half3(c, 0.0h, x);

    half m = v - c;
    return rgb + half3(m, m, m);
}

[[ stitchable ]] half4 sample
(
 float2 gid, // デフォルト
 half4 c0, // デフォルト
 float colorToDisplay,
 float range,
 half4 color
 ) {
    half3 hsb = rgb2hsb(c0.r, c0.g, c0.b);

    if (colorToDisplay - range < hsb.x && hsb.x < colorToDisplay + range) {

    } else {
        hsb.g = 0.0;
    }

    half3 rgb = hsb2rgb(hsb.r, hsb.g, hsb.b);

    return half4(rgb.r, rgb.g, rgb.b, c0.a);
}
