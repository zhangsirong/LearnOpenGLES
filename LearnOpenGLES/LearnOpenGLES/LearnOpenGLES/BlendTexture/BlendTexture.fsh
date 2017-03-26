varying mediump vec3 ourColor;
varying mediump vec2 TexCoord;

uniform sampler2D ourTexture1;
uniform sampler2D ourTexture2;

void main(void) {

//    gl_FragColor = vec4(ourColor, 1.0);
//    gl_FragColor = texture2D(ourTexture2, TexCoord);
//    gl_FragColor = texture2D(ourTexture1, TexCoord) * vec4(ourColor, 1.0);
    gl_FragColor = mix(texture2D(ourTexture1, TexCoord), texture2D(ourTexture2, TexCoord), 0.2);
//    gl_FragColor = mix(texture2D(ourTexture1, TexCoord), texture2D(ourTexture2, TexCoord), 0.2) * vec4(ourColor, 1.0);
//    gl_FragColor = mix(texture2D(ourTexture1, TexCoord), texture2D(ourTexture2, vec2(1.0 - TexCoord.x, TexCoord.y)), 0.2);



}
