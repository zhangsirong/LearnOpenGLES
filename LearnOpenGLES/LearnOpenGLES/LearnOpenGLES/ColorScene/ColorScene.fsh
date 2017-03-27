precision highp float;

uniform vec3 objectColor;
uniform vec3 lightColor;

void main(void) {

    gl_FragColor = vec4(objectColor * lightColor, 1.0);
    
//    //Ambient Lighting
//    float ambientStrength = 0.1;
//    vec3 ambient = ambientStrength * lightColor;
//    vec3 result = ambient * objectColor;
//    gl_FragColor = vec4(result, 1.0);
}
