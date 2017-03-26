varying mediump vec3 ourColor;
varying mediump vec2 TexCoord;

uniform sampler2D ourTexture;


void main(void) {

//    gl_FragColor = vec4(ourColor, 1.0);
//    gl_FragColor = texture2D(ourTexture, TexCoord);
    gl_FragColor = texture2D(ourTexture, TexCoord) * vec4(ourColor, 1.0);
}
