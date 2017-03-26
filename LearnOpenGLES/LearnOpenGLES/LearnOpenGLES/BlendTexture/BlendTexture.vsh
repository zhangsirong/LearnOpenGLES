attribute vec3 sourceColor;
attribute vec3 position;
attribute vec2 texCoord;

varying mediump vec3 ourColor;
varying mediump vec2 TexCoord;


void main(void) {
    
    ourColor = sourceColor;
//    TexCoord = texCoord;
    TexCoord = vec2(texCoord.x, 1.0 - texCoord.y);
    gl_Position = vec4(position,1.0);
}
