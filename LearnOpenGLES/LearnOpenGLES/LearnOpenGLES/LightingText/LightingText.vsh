attribute vec3 position;
attribute vec3 normal;
attribute vec2 texCoords;

varying mediump vec3 Normal;
varying mediump vec3 FragPos;
varying mediump vec2 TexCoords;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main(void) {
    
    FragPos = vec3(model * vec4(position, 1.0));
    Normal = normal;
    TexCoords = texCoords;

//    Normal = mat3(transpose(inverse(model))) * normal;
    gl_Position = projection * view * model * vec4(position,1.0);


}
