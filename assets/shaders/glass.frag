#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float radius;
    float grayAmt;
    float boost;
    vec2 texel;
} ubuf;

layout(binding = 1) uniform sampler2D tex;

void main()
{
    vec2 uv = qt_TexCoord0;
    vec2 d = ubuf.texel * ubuf.radius;
    vec4 c = texture(tex, uv) * 0.20;
    c += texture(tex, uv + vec2( d.x, 0.0)) * 0.12;
    c += texture(tex, uv + vec2(-d.x, 0.0)) * 0.12;
    c += texture(tex, uv + vec2(0.0,  d.y)) * 0.12;
    c += texture(tex, uv + vec2(0.0, -d.y)) * 0.12;
    c += texture(tex, uv + vec2( d.x,  d.y) * 0.7) * 0.08;
    c += texture(tex, uv + vec2(-d.x, -d.y) * 0.7) * 0.08;
    c += texture(tex, uv + vec2( d.x, -d.y) * 0.7) * 0.08;
    c += texture(tex, uv + vec2(-d.x,  d.y) * 0.7) * 0.08;
    float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    c.rgb = mix(c.rgb, vec3(lum), ubuf.grayAmt);
    fragColor = vec4(c.rgb * ubuf.boost, 1.0) * ubuf.qt_Opacity;
}
