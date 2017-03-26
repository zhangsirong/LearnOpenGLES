attribute vec3 position;
attribute vec2 texCoord;

varying mediump vec2 TexCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main(void) {
    
    TexCoord = vec2(texCoord.x, 1.0 - texCoord.y);
    
    // read from right to left 
    gl_Position = projection * view * model * vec4(position,1.0);


}
