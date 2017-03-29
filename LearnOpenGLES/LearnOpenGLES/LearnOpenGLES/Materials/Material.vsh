attribute vec3 position;
attribute vec3 normal;

varying mediump vec3 Normal;
varying mediump vec3 FragPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main(void) {
    
    FragPos = vec3(model * vec4(position, 1.0));
    Normal = normal;
//    Normal = mat3(transpose(inverse(model))) * normal;

    gl_Position = projection * view * model * vec4(position,1.0);


}
