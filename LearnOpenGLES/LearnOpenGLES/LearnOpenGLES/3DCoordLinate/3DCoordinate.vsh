attribute vec3 sourceColor;
attribute vec3 position;
attribute vec2 texCoord;

varying mediump vec3 ourColor;
varying mediump vec2 TexCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main(void) {
    
    ourColor = sourceColor;
    TexCoord = vec2(texCoord.x, 1.0 - texCoord.y);
    
    // read from right to left 
    gl_Position = projection * view * model * vec4(position,1.0);


}
