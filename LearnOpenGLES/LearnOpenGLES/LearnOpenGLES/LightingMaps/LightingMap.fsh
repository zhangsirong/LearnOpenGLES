precision highp float;
uniform sampler2D ourTexture1;
struct Material
{
    sampler2D diffuse;
    
    vec3 specular;
    float shininess;
};

struct Light {
    vec3 position;
    
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

varying mediump vec3 Normal;
varying mediump vec3 FragPos;
varying mediump vec2 TexCoords;

uniform vec3 viewPos;
uniform Material material;
uniform Light light;


void main(void) {
    
    // Ambient
    vec3 ambient = light.ambient * vec3(texture2D(material.diffuse, TexCoords));

    // Diffuse
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(light.position - FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture2D(material.diffuse, TexCoords));

    //https://learnopengl-cn.github.io/02%20Lighting/04%20Lighting%20maps/
    // Specular
    vec3 viewDir = normalize(viewPos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = light.specular * (spec * material.specular);

    vec3 result = ambient + diffuse + specular;
    gl_FragColor = vec4(result, 1.0);

}
