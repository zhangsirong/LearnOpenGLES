attribute vec3 position;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main(void) {
    
    // read from right to left
    gl_Position = projection * view * model * vec4(position,1.0);


}
