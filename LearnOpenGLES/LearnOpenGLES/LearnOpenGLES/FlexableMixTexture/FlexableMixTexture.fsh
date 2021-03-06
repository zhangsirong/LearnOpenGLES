varying mediump vec3 ourColor;
varying mediump vec2 TexCoord;

uniform sampler2D ourTexture1;
uniform sampler2D ourTexture2;

uniform lowp float mixValue;

void main(void) {
    gl_FragColor = mix(texture2D(ourTexture1, TexCoord), texture2D(ourTexture2, TexCoord), mixValue);
}
