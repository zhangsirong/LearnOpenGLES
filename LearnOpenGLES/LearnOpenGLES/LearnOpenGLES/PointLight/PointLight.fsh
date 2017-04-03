precision highp float;
struct Material
{
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

struct Light {
    vec3 position;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    
    float constant;//衰减函数的3个系数
    float linear;
    float quadratic;
};

varying mediump vec3 Normal;
varying mediump vec3 FragPos;
varying mediump vec2 TexCoords;

uniform vec3 viewPos;
uniform Material material;
uniform Light light;


void main(void) {
    
    // Ambient 环境分量
    vec3 ambient = light.ambient * vec3(texture2D(material.diffuse, TexCoords));

    // Diffuse 漫反射分量
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(light.position - FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture2D(material.diffuse, TexCoords));

    //https://learnopengl-cn.github.io/02%20Lighting/05%20Light%20casters/
    // Specular 镜面分量
    vec3 viewDir = normalize(viewPos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = light.specular * spec * vec3(texture2D(material.specular, TexCoords));
    
    // 衰减
    float distance    = length(light.position - FragPos);
    float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * (distance * distance));
    
    ambient  *= attenuation;
    diffuse  *= attenuation;
    specular *= attenuation;
    
    vec3 result = ambient + diffuse + specular;
    gl_FragColor = vec4(result, 1.0);

}
